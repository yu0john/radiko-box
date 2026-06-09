import RPi.GPIO as GPIO
import time
import os

# set pin number
BTN = 23

GPIO.setmode(GPIO.BCM)
# PUD_UP. 0 when button pressed, 1 when not pressed
GPIO.setup(BTN, GPIO.IN, pull_up_down=GPIO.PUD_UP)

print("Power Button Monitoring...")

try:
    while True:
        # when pressed
        if GPIO.input(BTN) == GPIO.LOW:
            # start recording duration of press
            start_time = time.time()

            while GPIO.input(BTN) == GPIO.LOW:
                elapsed_time = time.time() - start_time
                if elapsed_time >= 2.0:
                    break
                time.sleep(0.1)

            if time.time() - start_time >= 2.0:
                os.system("sudo shutdown -h now")
                break

            else:
                print("Short press. Nothing will happen")
                time.sleep(0.3)

        time.sleep(0.1)

except KeyboardInterrupt:
    # clear pin assign
    GPIO.cleanup()
    print("\nPower Button Monitoring terminated")
