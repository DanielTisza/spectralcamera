# ----------------------------------------------------------------------------
#	test_fpi_with_led.py
#
#	Copyright 2022 Daniel Tisza
#	MIT License
#
#	Test controlling FPI module and LED module
#
# ----------------------------------------------------------------------------

# For LED imports
import os
import platform
import sys

import serial
import serial.tools.list_ports as list_ports
from serial import Serial

# For FPI imports
import fpipy as fp

from spectracular.fpi_driver import detectFPIDevices, createFPIDevice

		
FPI_IDS = [
    # ( VID,   PID) (and the same in decimal)
    ('1FC9', '0083'), (8137, 131),
    ]
"""Known VID:PID pairs of FPI devices."""
FPI_HWIDS = [
    # Strings returned by read_hardware_id
	 'd02b012 af380065 5b5bbeab f50019c1'
]

fpi = createFPIDevice(detectFPIDevices(FPI_IDS, FPI_HWIDS)[0].device)
print(fpi)

print("_hw_id: " + str(fpi._hw_id))

print("_hw_info: [" + str(fpi._hw_info) + "]")

print("_eeprom: ")
print(fpi._eeprom)

# MFPI specific
print("_expected_settling_time: " + str(fpi._expected_settling_time))
print("_setpoint_cmd: " + str(fpi._setpoint_cmd))
print("_current_setpoint: " + str(fpi._current_setpoint))

# MFPI parseEeprom()
print("_is_AC: " + str(fpi._is_AC))
print("_name: " + str(fpi._name))
print("_eeprom_id: " + str(fpi._eeprom_id))
print("_dn_max: " + str(fpi._dn_max))
print("_dn_min: " + str(fpi._dn_min))

# MFPI getTemperature()
print("getTemperature(): " + str(fpi.getTemperature()))

#----------------------------------------- 
#  LED driver
#-----------------------------------------

# ledportstring = '/dev/ttyACM1'
# ledportstring = 'COM10'

# HP laptop when LED connected on right side USB port
ledportstring = 'COM7'

print('Trying to use ' + ledportstring + ' for LED control')
port = serial.Serial(ledportstring, 9600, timeout=0.5)

# MFPI setSetpoint()

# 3	72	1	52164	0	0	554.0473012	0	0	-0.167038819	0.897291038	-1.106291748	0	0	0	0	0	0	20.36692413	0	0
# 3	112	1	46815	0	0	600.3957949	0	0	0.63670834	0.421133211	-0.719467142	0	0	0	0	0	0	22.66214846	0	0
# 4	121	1	53506	0	0	695.9738452	0	0	0.746581945	0.746581945	0.746581945	0	0	0	0	0	0	30.93814177	0	0
# 6	190	1	44248	0	0	800.8814747	0	0	0.930350147	0.930350147	0.930350147	0	0	0	0	0	0	25.21518763	0	0

# Turn off
print('LEDs turn off with 0x0')
input("Press to activate")
port.flushOutput()
port.flushInput()
port.write(str.encode('L0x0\r\n'))

print("_current_setpoint: " + str(fpi._current_setpoint))

#C
print('LEDs on for set C [3]')
input("Press to activate")
#led.L(0b000000001000000001000000001) 40201
port.flushOutput()
port.flushInput()
port.write(str.encode('L0x40201\r\n'))
port.flushOutput()
port.flushInput()

fpi.setSetpoint(52164)
print("_current_setpoint: " + str(fpi._current_setpoint))

fpi.setSetpoint(46815)
print("_current_setpoint: " + str(fpi._current_setpoint))

#D
print('LEDs on for set D [4]')
input("Press to activate")
#led.L(0b000011110000011110000011110) 783C1E
port.flushOutput()
port.flushInput()
port.write(str.encode('L0x783C1E\r\n'))
port.flushOutput()
port.flushInput()


fpi.setSetpoint(53506)
print("_current_setpoint: " + str(fpi._current_setpoint))

#F
print('LEDs on for set F [6]')
input("Press to activate")
#led.L(0b001111000001111000001111000) 1E0F078
port.flushOutput()
port.flushInput()
port.write(str.encode('L0x1E0F078\r\n'))
port.flushOutput()
port.flushInput()

fpi.setSetpoint(44248)
print("_current_setpoint: " + str(fpi._current_setpoint))


# Turn off
print('LEDs turn off with 0x0')
input("Press to activate")
port.flushOutput()
port.flushInput()
port.write(str.encode('L0x0\r\n'))

