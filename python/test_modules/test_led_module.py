# ----------------------------------------------------------------------------
#	test_led_module.py
#
#	Copyright 2021 Daniel Tisza
#	MIT License
#
#	Test creating LED module instance
#
# ----------------------------------------------------------------------------

import matplotlib

from LEDDriver import detect_LED_devices, LEDDriver, LEDException

LED_IDS = [
    # ( VID,   PID) (and the same in decimal)
    ('1FC9', '0083'), (8137, 131),
    ]
"""Known VID:PID pairs of LED devices."""
LED_HWIDS = [
    # Strings returned by read_hardware_id
    '1000e016 aefba123 580267dd f5001982',
	'10025018 af28a028 5a66a511 f5001983'
]

ledportdevice = detect_LED_devices()
print(ledportdevice[0])

led = LEDDriver('COM14')
print(led)

led.open()

print('Turning on LEDs')

# VIS
#  
# 695,973845208697 … 738,7581953
#
# LED2/680nm, LED3/720nm, LED4/750nm, LED5/780nm
# LED11/680nm, LED12/720nm, LED13/750nm, LED14/780nm
# LED20/680nm, LED21/720nm, LED22/750nm, LED23/780nm
#
led.L(0b000011110000011110000011110)
