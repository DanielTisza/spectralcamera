# ----------------------------------------------------------------------------
#	led_set_b.py
#
#	Copyright 2021 Daniel Tisza
#	MIT License
#
#	Acquiring LED set B wavelengths radiance and reflectance
#
# ----------------------------------------------------------------------------

import fpipy as fp
import matplotlib

from camazing import CameraList
from spectracular.fpi_driver import detectFPIDevices, createFPIDevice
from spectracular.hsi import HSI

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

led = LEDDriver('COM10')
print(led)

led.open()

print('Turning off LEDs')
led.L(0)


cameras = CameraList()
print(cameras)

camera = cameras[0]
camera.initialize()
		
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

hsi = HSI(camera, fpi)
print(hsi)
hsi.read_calibration_file('led_set_b_calib.txt')

camera["TriggerMode"].value = "On"
camera["TriggerSource"].value = "Software"
camera["ExposureAuto"].value = "Off"
camera["PixelFormat"].value = "BayerGB12"
# camera["ExposureTime"].value = 100000
# camera["ExposureTime"].value = 60000
camera["ExposureTime"].value = 25000
# camera["ExposureTime"].value = 10000
camera["BalanceWhiteAuto"].value = "Off"
camera["Gamma"].value = 1
camera["Gain"].value = 1.9382002601
camera["GainAuto"].value = "Off"

input("Put the lens cap on")
hsi.take_dark_reference()
print(hsi.dataset.dark)

input("Take the lens cap off and set white reference")

print('Turning on LEDs')

# VIS
#  
# 533.8275323
# 568.2446615
#
# 687.9319591
# 696.8895468
#
# 110000000110000000110000000
# * Reverse for LED control:
# 000000011000000011000000011
#
led.L(0b000000011000000011000000011)
print('Capturing white reference')
white_raw = hsi.capture_cube()

input("Set image (only for radiance)")

print('Capturing cube')
raw = hsi.capture_cube()
print(raw)

print('Turning off LEDs')
led.L(0)

print('Calculating radiance')
rad = fp.raw_to_radiance(raw, keep_variables=['dark'])
print(rad)
print(rad['radiance'])

print('Calculating white radiance')
rad['white'] = fp.raw_to_radiance(white_raw, keep_variables = []).radiance
print(rad['white'])

print('Calculating reflectance')
rad['reflectance'] = rad.radiance / rad.white
print(rad['reflectance'])

# reflectance = fp.radiance_to_reflectance(rad, white_raw, keep_variables=[])
# print(reflectance)

print('Extracting single frame from cube and saving to PNG')
test = rad["radiance"]

print('Radiance data')
testdata = test.data
print(testdata)

print('White data')
whitedata = rad['white'].data
print(whitedata)

print('Reflectance data')
reflectdata = rad['reflectance'].data
print(reflectdata)

print ("Wavelengths")
wavelengths = rad["wavelength"].data
print(wavelengths)

print ("Wavelengths count")
wavelengthCount = len(wavelengths)
print(wavelengthCount)

# Multiple peaks result in multiple of single calib file row count
imagelastindex = wavelengthCount

#
# Save radiance images
#
print('Start saving radiance images')
for x in range(0, imagelastindex):

	wavelengthValue = wavelengths[x]
	wavelengthStr = str(wavelengthValue)
	wavelengthReplacedStr = wavelengthStr.replace(".", "p")
	print('Saving wavelength: ' + wavelengthStr)
	
	rad1 = testdata[:,:,x]
	matplotlib.image.imsave('rad_' + wavelengthReplacedStr + 'nm_' + str(x) + '.png', rad1)

	white1 = whitedata[:,:,x]
	# matplotlib.image.imsave('white_' + wavelengthReplacedStr + 'nm_' + str(x) + '.png', white1)
	
	ref1 = reflectdata[:,:,x]
	matplotlib.image.imsave('refl_' + wavelengthReplacedStr + 'nm_' + str(x) + '.png', ref1, vmin=0,vmax=1)



import matplotlib.pyplot as plt
plt.gray()

#
# Save raw images and demosaic images
#
print('Start saving raw data')
for x in range(1, 2):

	# Raw data values
	dn1 = raw.dn.isel(index=x)
	matplotlib.image.imsave('raw_' + str(x) + '.png', dn1)

	# Demosaic to get three colour channels
	dm1 = fp.demosaic(dn1, 'BayerGB', 'bilinear')
	dm1_red = dm1[:,:,0]
	dm1_green = dm1[:,:,1]
	dm1_blue = dm1[:,:,2]

	matplotlib.image.imsave('raw_' + str(x) + '_demosaic_red.png', dm1_red)
	matplotlib.image.imsave('raw_' + str(x) + '_demosaic_green.png', dm1_green)
	matplotlib.image.imsave('raw_' + str(x) + '_demosaic_blue.png', dm1_blue)

