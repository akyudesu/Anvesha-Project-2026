from machine import ADC, Pin
import time
import dht

NAME = "ESP 32 B"
THRESHOLD = 1300

buzzer = Pin(25, Pin.OUT)
buzzer.value(0)

mq2_sensors = {
    "BLOCK A": 32,
    "BLOCK B": 33,
}

sensors = {}
for sensor, pin in mq2_sensors.items():
    adc = ADC(Pin(pin))
    adc.atten(ADC.ATTN_11DB)
    sensors[sensor] = adc

print("Monitoring all zones...")

def potentialFireMsg(room, smokeVal):
    print(f"Fire in room: {room}, and smoke density: {smokeVal}")
    print(f"Data from: {NAME}")
    print("Starting Buzzer sounds...")


def run_fire_safety_system():
    buzzer_state = 0

    while True:
        current_reading = {}
        for name, adc in sensors.items():
            current_reading[name] = adc.read()

        highestRoom = max(current_reading, key=current_reading.get)
        highestValue = current_reading[highestRoom]

        print("\n------ ZONE OVERVIEW ------")
        for name, value in current_reading.items():
            print(f"{name}: {value}")
        

        fire_by_smoke = highestValue > THRESHOLD

        if fire_by_smoke:

            if fire_by_smoke:
                potentialFireMsg(highestRoom, highestValue)

            buzzer_state = 1 - buzzer_state
            buzzer.value(buzzer_state)
        else:
            print("System Status: No Fire Anywhere")
            buzzer.value(0)
            buzzer_state = 0

        time.sleep(1)

run_fire_safety_system()
