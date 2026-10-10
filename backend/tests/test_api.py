import os
import unittest
from unittest.mock import patch

from fastapi.testclient import TestClient

from backend.api import server


class SensorApiTests(unittest.TestCase):
    def setUp(self) -> None:
        self.client = TestClient(server.app)
        self.environment = patch.dict(
            os.environ,
            {
                "DEVICE_API_TOKEN": "test-token",
                "SUPABASE_URL": "https://example.supabase.co",
                "SUPABASE_SECRET_KEY": "test-secret",
            },
        )
        self.environment.start()
        self.addCleanup(self.environment.stop)

    def test_status_reports_service_and_configuration(self) -> None:
        response = self.client.get("/status")

        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.json()["status"], "ok")
        self.assertTrue(response.json()["device_ingestion_configured"])

    def test_status_is_degraded_without_server_configuration(self) -> None:
        with patch.dict(
            os.environ,
            {
                "DEVICE_API_TOKEN": "",
                "SUPABASE_URL": "",
                "SUPABASE_SECRET_KEY": "",
            },
        ):
            response = self.client.get("/status")

        self.assertEqual(response.json()["status"], "degraded")
        self.assertFalse(response.json()["database_configured"])
        self.assertFalse(response.json()["device_ingestion_configured"])

    def test_dashboard_requires_a_supabase_bearer_token(self) -> None:
        response = self.client.get("/dashboard")

        self.assertEqual(response.status_code, 401)

    def test_dashboard_allows_browser_authorization_preflight(self) -> None:
        response = self.client.options(
            "/dashboard",
            headers={
                "Origin": "http://localhost:53000",
                "Access-Control-Request-Method": "GET",
                "Access-Control-Request-Headers": "authorization",
            },
        )

        self.assertEqual(response.status_code, 200)
        self.assertEqual(
            response.headers["access-control-allow-origin"],
            "*",
        )
        self.assertIn(
            "authorization",
            response.headers["access-control-allow-headers"].lower(),
        )
        self.assertIn("GET", response.headers["access-control-allow-methods"])

    def test_dashboard_forwards_supabase_token_to_database_service(self) -> None:
        snapshot = {
            "zones": [],
            "devices": [],
            "sensors": [],
            "sensor_readings": [],
            "occupancy_readings": [],
            "zone_risks": [],
            "incidents": [],
            "alerts": [],
            "routes": [],
            "user_profile": None,
        }
        with patch.object(
            server.db, "get_dashboard_snapshot", return_value=snapshot
        ) as get_snapshot:
            response = self.client.get(
                "/dashboard",
                headers={"Authorization": "Bearer supabase-access-token"},
            )

        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.json(), snapshot)
        get_snapshot.assert_called_once_with("supabase-access-token")

    def test_sensor_report_is_persisted_and_returns_summary(self) -> None:
        expected = {
            "device_uid": "ESP 32 A",
            "stored_readings": 2,
            "alerts": [],
            "status": "safe",
            "key": "ESP 32 A",
        }
        with patch.object(
            server.db, "persist_sensor_report", return_value={**expected}
        ) as persist:
            response = self.client.post(
                "/sensor_readings",
                headers={"X-Device-Token": "test-token"},
                json={
                    "key": "ESP 32 A",
                    "readings": {"BLOCK A": 210, "BLOCK B": 125},
                    "temp": 24.5,
                },
            )

        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.json(), expected)
        persist.assert_called_once_with(
            device_uid="ESP 32 A",
            readings={"BLOCK A": 210, "BLOCK B": 125},
            temperature=24.5,
            occupancy={},
        )

    def test_invalid_zone_is_rejected_before_persistence(self) -> None:
        with patch.object(server.db, "persist_sensor_report") as persist:
            response = self.client.post(
                "/sensor_readings",
                headers={"X-Device-Token": "test-token"},
                json={"key": "ESP 32 A", "readings": {"BLOCK F": 100}},
            )

        self.assertEqual(response.status_code, 422)
        persist.assert_not_called()

    def test_missing_or_invalid_device_token_is_rejected(self) -> None:
        response = self.client.post(
            "/sensor_readings",
            headers={"X-Device-Token": "wrong-token"},
            json={"key": "ESP 32 B", "readings": {"BLOCK E": 100}},
        )

        self.assertEqual(response.status_code, 401)


if __name__ == "__main__":
    unittest.main()
