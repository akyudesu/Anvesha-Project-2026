from machine import ADC, Pin  #Machine is a module in ESP32 and ADC [ANALOG TO DIGITAL CONVERTER] and Pins are the pins on the board
import time #Impports time
import dht #A module in machine
import neopixel #A module in machine
import random #For getting random numbers

NAME = "ESP 32 A"
THRESHOLD = 1300

buzzer = Pin(25, Pin.OUT)
buzzer.value(0)

NUM_LEDS = 'x'
strip = neopixel.NEOPIXEL(Pin(22), NUM_LEDS)

mq2_sensors = {
    "BLOCK A": 32,
    "BLOCK B": 33,
    "BLOCK C": 34,
    "BLOCK D": 35,
}

sensors = {}
for sensor, pin in mq2_sensors.items():
    adc = ADC(Pin(pin))
    adc.atten(ADC.ATTN_11DB)
    sensors[sensor] = adc

dht_sensor = dht.DHT22(Pin(23))

print("Monitoring all zones...")

def evacuation_gradient_lights(danger_zone, key): #CHANGES LIGHT GRADIENT ACCORDING TO SMOKE AND TEMPRATURE
    if key == "ESP 32 A":
        for i in range(NUM_LEDS):

            position_ratio = i / (NUM_LEDS - 1)

            if danger_zone == "BLOCK A":
                r = int(255 * (1 - position_ratio))
                g = int(255 * position_ratio)
                b = 0

            elif danger_zone == "BLOCK B":
                r = int(255 * (1 - position_ratio))
                g = int(255 * position_ratio)
                b = 0

            elif danger_zone == "BLOCK D":
                r = int(255 * (1 - position_ratio))
                g = int(255 * position_ratio)
                b = 0

            elif danger_zone == "BLOCK C":
                r = int(255 * (1 - position_ratio))
                g = int(255 * position_ratio)
                b = 0
            else:
                r, g, b = 0, 255, 0

        strip[i] = (r, g, b)
strip.write()

evacuation_gradient_lights("ESP 32 A")

def get_smoke_desnity(room, smokeVal, key): #GETS SMOKE DENSITY IN THE ROOM
    if key == "ESP 32 A":
        return room, smokeVal

def get_cafe_temp(temp, key): #GETS CAFE TEMPRATURE
    if key == "ESP 32 A":
        msg = "cafeteria temprature"
        return msg, temp

def potentialFireMsg(room, smokeVal, key): #POTENTIAL FIRE MSG AND SARTS BUZZER
    if key == "ESP 32 A":
        print(f"Fire in room: {room}, and smoke density: {smokeVal}")
        print(f"Data from: {NAME}")
        print("Starting Buzzer sounds...")

def SuddenTemperatureIncrease(temp, key): #POTENTIAL FIRE IN CAFE AND BUZZER
    if key == "ESP 32 A":
        print(f"Sudden increase in temperature in cafe! Current: {temp}°C. Start evacuation!")

def run_fire_safety_system(key): #CONTINOUSLY RUNS AND CHECK TEMPRATURE AND SMOKE DENSITY
    if key == "ESP 32 A":
        buzzer_state = 0

        while True:
            try:
                dht_sensor.measure()
                temp = dht_sensor.temperature()
                temp_valid = True
            except OSError:
                temp = 0
                temp_valid = False
                print("Cannot read temperature, broken sensor possible.")

            current_reading = {}
            for name, adc in sensors.items():
                current_reading[name] = adc.read()



            highestRoom = max(current_reading, key=current_reading.get)
            highestValue = current_reading[highestRoom]

            print("\n------ ZONE OVERVIEW ------")
            for name, value in current_reading.items():
                print(f"{name}: {value}")
            
            if temp_valid:
                print(f"Cafeteria Temp: {temp}°C")
            else:
                print("Cafeteria Temp: ERROR")

            fire_by_smoke = highestValue > THRESHOLD
            fire_by_temp = temp_valid and temp > 55

            if fire_by_smoke or fire_by_temp:

                if fire_by_smoke:
                    potentialFireMsg(highestRoom, highestValue)
                if fire_by_temp:
                    SuddenTemperatureIncrease(temp)

                buzzer_state = 1 - buzzer_state
                buzzer.value(buzzer_state)
            else:
                print("System Status: No Fire Anywhere")
                buzzer.value(0)
                buzzer_state = 0

            time.sleep(1)

run_fire_safety_system("ESP 32 A")

def get_amount_of_people(key): #RANDOM AMOUNT OF PEOPLE IN BLOCK A,B,C,D
    if key == "ESP 32 A":
        people = random.randint(1, 430)
        return people

def get_amount_of_heads_in_class(key): #RANDOM AMOUNT OF HEADS IN A CLASS
    if key == "ESP 32 A":
        heads = random.randint(1, 43)
        return heads