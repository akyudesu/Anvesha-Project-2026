from machine import ADC, Pin  #Machine is a module in ESP32 and ADC [ANALOG TO DIGITAL CONVERTER] and Pins are the pins on the board
import time #Impports time
import random #For getting random numbers

NAME = "ESP 32 B"
THRESHOLD = 1300

buzzer = Pin(25, Pin.OUT)
buzzer.value(0)

mq2_sensors = {
    "BLOCK E": 32,
    "BLOCK F": 33,
}

sensors = {}
for sensor, pin in mq2_sensors.items():
    adc = ADC(Pin(pin))
    adc.atten(ADC.ATTN_11DB)
    sensors[sensor] = adc

print("Monitoring all zones...")

def potentialFireMsg(room, smokeVal, key):
    if key == "ESP 32 B":
        print(f"Fire in room: {room}, and smoke density: {smokeVal}")
        print(f"Data from: {NAME}")
        print("Starting Buzzer sounds...")

def get_smoke_desnity(room, smokeVal, key):
    if key == "ESP 32 B":
        return room, smokeVal

def run_fire_safety_system(key):
    if key == "ESP 32 B":
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

run_fire_safety_system("ESP 32 B")

def get_amount_of_people(key):
    if key == "ESP 32 B":
        people = random.randint(1, 430)
        return people

def get_amount_of_heads_in_class(key):
    if key == "ESP 32 B":
        heads = random.randint(1, 43)
        return heads