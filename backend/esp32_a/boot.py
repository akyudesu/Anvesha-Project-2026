import network
import time

sta = network.WLAN(network.STA_IF)
sta.active(True)

SSID = "Anish's Phone"
PASSWORD = 123456789

if not sta.connected():
    sta.connect(SSID, PASSWORD)

    while not wlan.isconnected():
        time.sleep(2)

print("CONNECTED SUCCESSFULLY")
print("Network configuration (IP, Gateway, Mask, DNS):", wlan.ifconfig())