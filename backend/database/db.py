import os
import time
from dotenv import load_dotenv
from postgrest import APIError
from supabase import Client, create_client

from esp32_a import main as main_a
from esp32_b import main as main_b

load_dotenv()

supabase_url = os.environ.get("SUPABASE_URL")
supabase_key = os.environ.get("SUPABASE_PUBLISHABLE_KEY")

if not supabase_url or not supabase_key:
    raise ValueError("Missing SUPABASE_URL or SUPABASE_PUBLISHABLE_KEY in environment variables.")

supabase: Client = create_client(supabase_url, supabase_key)


def save_fire_alert_a(room, smoke_val, messages=None, cafe_temp=None):
    """Saves sensor data and alert messages for ESP 32 A to Supabase."""
    msg_a, msg_b, msg_c = messages if messages else ("No Fire", "Data from ESP 32 A", "Buzzer OFF")

    payload = {
        "device_id": "ESP 32 A",
        "room": room,
        "smoke_density": smoke_val,
        "cafe_temp": cafe_temp,
        "alert_msg": msg_a,
        "source_msg": msg_b,
        "action_msg": msg_c,
        "is_fire": messages is not None
    }

    try:
        response = supabase.table("fire_safety_logs").insert(payload).execute()
        print(f"[Supabase ESP A] Inserted record for {room}")
        return response.data
    except Exception as err:
        print(f"[Supabase ESP A Error]: {err}")


def save_fire_alert_b(room, smoke_val, messages=None):
    """Saves sensor data and alert messages for ESP 32 B to Supabase."""
    msg_a, msg_b, msg_c = messages if messages else ("No Fire", "Data from ESP 32 B", "Buzzer OFF")

    payload = {
        "device_id": "ESP 32 B",
        "room": room,
        "smoke_density": smoke_val,
        "alert_msg": msg_a,
        "source_msg": msg_b,
        "action_msg": msg_c,
        "is_fire": messages is not None
    }

    try:
        response = supabase.table("fire_safety_logs").insert(payload).execute()
        print(f"[Supabase ESP B] Inserted record for {room}")
        return response.data
    except Exception as err:
        print(f"[Supabase ESP B Error]: {err}")


def fetch_block_data():
    """Fetches smoke densities and cafe temperature from both ESP units."""
    smoke_data_a = {
        "BLOCK A": main_a.get_smoke_desnity("BLOCK A", "ESP 32 A"),
        "BLOCK B": main_a.get_smoke_desnity("BLOCK B", "ESP 32 A"),
        "BLOCK C": main_a.get_smoke_desnity("BLOCK C", "ESP 32 A"),
        "BLOCK D": main_a.get_smoke_desnity("BLOCK D", "ESP 32 A"),
    }

    smoke_data_b = {
        "BLOCK E": main_b.get_smoke_desnity("BLOCK E", "ESP 32 B"),
        "BLOCK F": main_b.get_smoke_desnity("BLOCK F", "ESP 32 B"),
    }

    _, cafe_temp = main_a.get_cafe_temp("ESP 32 A")

    return smoke_data_a, smoke_data_b, cafe_temp


def run_monitoring_loop():
    THRESHOLD = 1300

    while True:
        try:
            # 1. Fetch sensor readings
            smoke_data_a, smoke_data_b, cafe_temp = fetch_block_data()

            # 2. Process ESP 32 A (Blocks A-D)
            for room, (_, smoke_val) in smoke_data_a.items():
                if smoke_val > THRESHOLD:
                    msgs = main_a.potentialFireMsga(room, smoke_val, "ESP 32 A")
                    save_fire_alert_a(room, smoke_val, messages=msgs, cafe_temp=cafe_temp)
                else:
                    save_fire_alert_a(room, smoke_val, messages=None, cafe_temp=cafe_temp)

            # 3. Process ESP 32 B (Blocks E-F)
            for room, (_, smoke_val) in smoke_data_b.items():
                if smoke_val > THRESHOLD:
                    msgs = main_b.potentialFireMsg(room, smoke_val, "ESP 32 B")
                    save_fire_alert_b(room, smoke_val, messages=msgs)
                else:
                    save_fire_alert_b(room, smoke_val, messages=None)

            time.sleep(2)

        except APIError as err:
            print(f"Supabase API Error: {err}")
        except Exception as err:
            print(f"Unexpected Error: {err}")


if __name__ == "__main__":
    run_monitoring_loop()