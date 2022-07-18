# ----------------------------------------------------------------------------
#	test_fpi_module2.py
#
#	Copyright 2021 Daniel Tisza
#	MIT License
#
#	Test controlling FPI module instance
#
# ----------------------------------------------------------------------------

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

# MFPI setSetpoint()

# 3	72	1	52164	0	0	554.0473012	0	0	-0.167038819	0.897291038	-1.106291748	0	0	0	0	0	0	20.36692413	0	0
# 3	112	1	46815	0	0	600.3957949	0	0	0.63670834	0.421133211	-0.719467142	0	0	0	0	0	0	22.66214846	0	0
# 4	121	1	53506	0	0	695.9738452	0	0	0.746581945	0.746581945	0.746581945	0	0	0	0	0	0	30.93814177	0	0
# 6	190	1	44248	0	0	800.8814747	0	0	0.930350147	0.930350147	0.930350147	0	0	0	0	0	0	25.21518763	0	0

print("_current_setpoint: " + str(fpi._current_setpoint))

fpi.setSetpoint(52164)
print("_current_setpoint: " + str(fpi._current_setpoint))

fpi.setSetpoint(46815)
print("_current_setpoint: " + str(fpi._current_setpoint))

fpi.setSetpoint(53506)
print("_current_setpoint: " + str(fpi._current_setpoint))

fpi.setSetpoint(44248)
print("_current_setpoint: " + str(fpi._current_setpoint))

