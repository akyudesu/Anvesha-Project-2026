import random

from fastapi import FastAPI
from pydantic import BaseModel, Field

ESP32_A = "ESP 32 A"
ESP32_B = "ESP 32 B"
FIRE_SMOKE_THRESHOLD = 1300
CAFE_TEMPERATURE_THRESHOLD = 55
DEVICE_ZONES = {
    ESP32_A: {"BLOCK A", "BLOCK B", "BLOCK C", "BLOCK D"},
    ESP32_B: {"BLOCK E", "BLOCK F"},
}

app = FastAPI()


class SensorReadings(BaseModel):
    key: str
    readings: dict[str, int] = Field(min_length=1)
    temp: float | None = None


def _smoke_fire_response(key: str, room: str, smoke_val: int):
    return {
        "key": key,
        "room": room,
        "smoke_density": smoke_val,
        "message": f"Fire in room: {room}, and smoke density: {smoke_val}",
        "source": f"Data from: {key}",
        "alert": "Starting Buzzer sounds...",
    }


def dd_cafe_temperature_response(temp: float):
    return {
        "key": ESP32_A,
        "sensor": "cafeteria",
        "temperature": temp,
        "unit": "C",
        "alert": temp > CAFE_TEMPERATURE_THRESHOLD,
        "message": (
            f"Sudden increase in temperature in cafe! Current: {temp}°C. "
            "Start evacuation!"
            if temp > CAFE_TEMPERATURE_THRESHOLD
            else "Cafeteria temperature is within the safe range."
        ),
    }


@app.get("/")
async def read_root():
    return {"message": "Welcome to the Anvesha Project API!"}


@app.get("/status")
async def read_status():
    return {"status": "ok"}


@app.get("/student")
async def get_student_in_class(key: str, place: str):
    if key == ESP32_A and place == "class":
        return random.randint(1, 43)
    if key == ESP32_B and place == "class":
        return random.randint(1, 43)
    if key == ESP32_A and place == "block":
        return random.randint(1, 430)
    if key == ESP32_B and place == "block":
        return random.randint(1, 430)
    return {"error": "Invalid key or place parameter."}


@app.post("/smoke_density")
async def get_smoke_density(key: str, room: str, smokeVal: int):
    if key not in (ESP32_A, ESP32_B):
        return {"error": "Invalid key parameter."}
    return {"key": key, "room": room, "smoke_density": smokeVal}


@app.post("/cafe_temperature")
async def get_cafe_temperature(key: str, temp: float):
    if key != ESP32_A:
        return {"error": "Cafeteria temperature is available from ESP 32 A only."}
    return dd_cafe_temperature_response(temp)


@app.post("/evacuation_lights")
async def get_evacuation_light_directive(key: str, danger_zone: str):
    if key != ESP32_A:
        return {"error": "Evacuation lights are available from ESP 32 A only."}
    if danger_zone not in DEVICE_ZONES[ESP32_A]:
        return {"error": "Invalid danger_zone for ESP 32 A."}
    return {
        "key": key,
        "danger_zone": danger_zone,
        "effect": "red_to_green_gradient",
        "active": True,
    }


@app.post("/sensor_readings")
async def process_sensor_readings(payload: SensorReadings):
    if payload.key not in DEVICE_ZONES:
        return {"error": "Invalid key parameter."}
    invalid_zones = set(payload.readings) - DEVICE_ZONES[payload.key]
    if invalid_zones:
        return {
            "error": "Invalid room for device.",
            "rooms": sorted(invalid_zones),
        }
    if payload.key == ESP32_B and payload.temp is not None:
        return {"error": "Temperature readings are only supported for ESP 32 A."}

    highest_room = max(payload.readings, key=payload.readings.get)
    highest_value = payload.readings[highest_room]
    smoke_alert = highest_value > FIRE_SMOKE_THRESHOLD
    temperature_alert = (
        payload.key == ESP32_A
        and payload.temp is not None
        and payload.temp > CAFE_TEMPERATURE_THRESHOLD
    )

    result = {
        "key": payload.key,
        "readings": payload.readings,
        "highest_room": highest_room,
        "highest_smoke_density": highest_value,
        "status": "fire_detected" if smoke_alert or temperature_alert else "safe",
        "alerts": [],
    }
    if smoke_alert:
        result["alerts"].append(
            _smoke_fire_response(payload.key, highest_room, highest_value)
        )
    if payload.temp is not None:
        result["temperature"] = dd_cafe_temperature_response(payload.temp)
        if temperature_alert:
            result["alerts"].append(result["temperature"])
    return result


@app.post("/potential_fire")
async def potential_fire(
    key: str, room: str, smokeVal: int, temp: float | None = None
):
    if key == ESP32_B:
        return _smoke_fire_response(key, room, smokeVal)
    if key == ESP32_A:
        if temp is None:
            return _smoke_fire_response(key, room, smokeVal)
        return dd_cafe_temperature_response(temp)
    return {"error": "Invalid key parameter."}
