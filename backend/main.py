import os
import time
from dotenv import load_dotenv
from postgrest import APIError

import database as db

# MicroPython modules
import esp32_a
import esp32_b

load_dotenv()


def fetch_and_map_zones():
    """
    Looks up and maps room names to database zone UUIDs.
    """
    zone_mapping = {
        "BLOCK A": db.get_zone_id_by_name("C1"),
        "BLOCK B": db.get_zone_id_by_name("C2"),
        "BLOCK C": db.get_zone_id_by_name("C3"),
        "BLOCK D": db.get_zone_id_by_name("Corridor A"),
        "BLOCK E": db.get_zone_id_by_name("Corridor B"),
        "BLOCK F": db.get_zone_id_by_name("Exit A"),
    }
    return zone_mapping


def run_monitoring_loop():
    print("\n==================================================")
    print("  AEGIS GRID — Starting Central System Monitor   ")
    print("==================================================\n")

    zone_map = fetch_and_map_zones()

    # Register Devices according to schema
    device_a_id = db.get_or_create_device("ESP32-A", "ESP32 Controller Zone A", zone_map.get("BLOCK A"))
    device_b_id = db.get_or_create_device("ESP32-B", "ESP32 Controller Zone B", zone_map.get("BLOCK E"))

    # Register Sensors linked to registered devices
    smoke_sensors = {}
    for room in ["BLOCK A", "BLOCK B", "BLOCK C", "BLOCK D"]:
        smoke_sensors[room] = db.get_or_create_sensor(
            device_id=device_a_id,
            sensor_type="smoke",
            sensor_name=f"Smoke Sensor {room}",
            zone_id=zone_map.get(room),
            unit="ppm"
        )

    for room in ["BLOCK E", "BLOCK F"]:
        smoke_sensors[room] = db.get_or_create_sensor(
            device_id=device_b_id,
            sensor_type="smoke",
            sensor_name=f"Smoke Sensor {room}",
            zone_id=zone_map.get(room),
            unit="ppm"
        )

    temp_sensor_cafe = db.get_or_create_sensor(
        device_id=device_a_id,
        sensor_type="temperature",
        sensor_name="Cafeteria Temperature Sensor",
        zone_id=zone_map.get("BLOCK A"),
        unit="°C"
    )

    while True:
        try:
            # --- 1. COLLECT DATA FROM ESP 32 A ---
            _, smoke_a = esp32_a.get_smoke_desnity("BLOCK A", "ESP 32 A")
            _, smoke_b = esp32_a.get_smoke_desnity("BLOCK B", "ESP 32 A")
            _, smoke_c = esp32_a.get_smoke_desnity("BLOCK C", "ESP 32 A")
            _, smoke_d = esp32_a.get_smoke_desnity("BLOCK D", "ESP 32 A")
            cafe_msg_label, cafe_temp = esp32_a.get_cafe_temp("ESP 32 A")
            people_esp_a = esp32_a.get_amount_of_people("ESP 32 A")

            # --- 2. COLLECT DATA FROM ESP 32 B ---
            _, smoke_e = esp32_b.get_smoke_desnity("BLOCK E", "ESP 32 B")
            _, smoke_f = esp32_b.get_smoke_desnity("BLOCK F", "ESP 32 B")
            people_esp_b = esp32_b.get_amount_of_peopleb("ESP 32 B")

            smoke_readings = {
                "BLOCK A": smoke_a,
                "BLOCK B": smoke_b,
                "BLOCK C": smoke_c,
                "BLOCK D": smoke_d,
                "BLOCK E": smoke_e,
                "BLOCK F": smoke_f,
            }

            # --- 3. DETERMINE HIGHEST READINGS PER ZONE ---
            readings_a = {"BLOCK A": smoke_a, "BLOCK B": smoke_b, "BLOCK C": smoke_c, "BLOCK D": smoke_d}
            highest_room_a = max(readings_a, key=readings_a.get)
            highest_val_a = readings_a[highest_room_a]

            readings_b = {"BLOCK E": smoke_e, "BLOCK F": smoke_f}
            highest_room_b = max(readings_b, key=readings_b.get)
            highest_val_b = readings_b[highest_room_b]

            # --- 4. LOG ALL READINGS TO SENSOR_READINGS TABLE ---
            for room, val in smoke_readings.items():
                zone_id = zone_map.get(room)
                s_id = smoke_sensors.get(room)
                if s_id:
                    db.log_sensor_reading(
                        sensor_id=s_id,
                        zone_id=zone_id,
                        value=float(val),
                        unit="ppm"
                    )

            if cafe_temp is not None and temp_sensor_cafe:
                db.log_sensor_reading(
                    sensor_id=temp_sensor_cafe,
                    zone_id=zone_map.get("BLOCK A"),
                    value=float(cafe_temp),
                    unit="°C"
                )

            # Log Occupancy Readings
            if zone_map.get("BLOCK A"):
                db.log_occupancy_reading(zone_map.get("BLOCK A"), people_esp_a)
            if zone_map.get("BLOCK E"):
                db.log_occupancy_reading(zone_map.get("BLOCK E"), people_esp_b)

            # --- 5. CHECK & PROCESS ALERTS FOR ESP 32 A ---
            fire_alert_a = False
            msgs_a = None

            if highest_val_a > esp32_a.THRESHOLD:
                fire_alert_a = True
                msgs_a = esp32_a.potentialFireMsga(highest_room_a, highest_val_a, "ESP 32 A")
                target_zone_id = zone_map.get(highest_room_a)

                inc = db.create_incident(
                    zone_id=target_zone_id,
                    incident_type="smoke",
                    severity="critical" if highest_val_a > 500 else "high",
                    description=f"Smoke alert in {highest_room_a} with value {highest_val_a} ppm."
                )

                if inc:
                    db.create_alert(
                        title=f"FIRE RISK: {highest_room_a}",
                        message=msgs_a[0] if msgs_a else "Potential fire detected!",
                        severity="high",
                        zone_id=target_zone_id,
                        incident_id=inc["id"]
                    )

            if cafe_temp is not None and cafe_temp > 55:
                fire_alert_a = True
                temp_alert_msg = esp32_a.SuddenTemperatureIncrease(cafe_temp, "ESP 32 A")

                db.create_alert(
                    title="HIGH TEMPERATURE ALERT: Cafeteria",
                    message=temp_alert_msg,
                    severity="critical",
                    zone_id=zone_map.get("BLOCK A")
                )

            # --- 6. CHECK & PROCESS ALERTS FOR ESP 32 B ---
            fire_alert_b = False
            msgs_b = None

            if highest_val_b > esp32_b.THRESHOLD:
                fire_alert_b = True
                msgs_b = esp32_b.potentialFireMsg(highest_room_b, highest_val_b, "ESP 32 B")
                target_zone_id = zone_map.get(highest_room_b)

                inc = db.create_incident(
                    zone_id=target_zone_id,
                    incident_type="smoke",
                    severity="high",
                    description=f"Smoke alert in {highest_room_b} with value {highest_val_b} ppm."
                )

                if inc:
                    db.create_alert(
                        title=f"FIRE RISK: {highest_room_b}",
                        message=msgs_b[0] if msgs_b else "Potential fire detected!",
                        severity="high",
                        zone_id=target_zone_id,
                        incident_id=inc["id"]
                    )

            # --- 7. LOG SYSTEM SNAPSHOT EVENT TO DB ---
            overall_fire_alert = fire_alert_a or fire_alert_b
            snapshot_payload = {
                "smoke_levels": smoke_readings,
                "cafe_temp": cafe_temp,
                "people_count_zone_a": people_esp_a,
                "people_count_zone_b": people_esp_b,
                "is_fire": overall_fire_alert
            }
            db.log_system_event("MONITOR_SNAPSHOT", "main_controller", snapshot_payload, device_id=device_a_id)

            # --- 8. LOG TO CONSOLE ---
            print("\n---------------- SYSTEM SNAPSHOT ----------------")
            print(f"ESP A -> Max: {highest_room_a} ({highest_val_a} ppm) | Cafe Temp: {cafe_temp}°C | People: {people_esp_a}")
            print(f"ESP B -> Max: {highest_room_b} ({highest_val_b} ppm) | People: {people_esp_b}")
            print(f"Alert Status: {'🔥 CRITICAL FIRE ALERT 🔥' if overall_fire_alert else '✅ NORMAL'}")
            print("--------------------------------------------------")

            time.sleep(3)

        except APIError as err:
            print(f"[DATABASE API ERROR] {err}")
        except Exception as err:
            print(f"[UNEXPECTED ERROR] {err}")


if __name__ == "__main__":
    run_monitoring_loop()