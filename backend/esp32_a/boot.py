import time

import network

from device_config import WIFI_PASSWORD, WIFI_SSID


def connect_wifi():
    wlan = network.WLAN(network.STA_IF)
    wlan.active(True)
    if not wlan.isconnected():
        wlan.connect(WIFI_SSID, WIFI_PASSWORD)
        for _ in range(30):
            if wlan.isconnected():
                break
            time.sleep(1)
    if not wlan.isconnected():
        print("Wi-Fi connection failed; sensor monitoring will continue offline.")
        return False
    print("Wi-Fi connected:", wlan.ifconfig())
    return True


connect_wifi()
