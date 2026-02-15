import RPi.GPIO as GPIO
import os
import time

# pin number setting
CLK = 5
DT = 6
SW = 25

GPIO.setmode(GPIO.BCM)
GPIO.setup(CLK, GPIO.IN, pull_up_down=GPIO.PUD_UP)
GPIO.setup(DT, GPIO.IN, pull_up_down=GPIO.PUD_UP)
GPIO.setup(SW, GPIO.IN, pull_up_down=GPIO.PUD_UP)

# initialization
last_clk = GPIO.input(CLK)

print("volume control service started")

try:
    while True:
        # for rotation
        current_clk = GPIO.input(CLK)
        if current_clk != last_clk:
            if GPIO.input(DT) != current_clk:
                os.system("mpc volume +2")
            else:
                os.system("mpc volume -2")
        last_clk = current_clk

        # for press
        if GPIO.input(SW) == 0:
            print("Button Pressed")
            os.system("mpc toggle")
            # wait till released
            while GPIO.input(SW) == 0:
                time.sleep(0.1)

        time.sleep(0.005)

except KeyboardInterrupt:
    GPIO.cleanup()
    print("\nExit.")
