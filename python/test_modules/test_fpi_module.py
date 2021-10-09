# ----------------------------------------------------------------------------
#	test_fpi_module.py
#
#	Copyright 2021 Daniel Tisza
#	MIT License
#
#	Test creating FPI module instance
#
# ----------------------------------------------------------------------------

import fpipy as fp
import matplotlib

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

