# ----------------------------------------------------------------------------
#	test17.py
#
#	Copyright 2021 Daniel Tisza
#	MIT License
#
#	Taking raw image with Zybo and saving to NETCDF
#
#	LED calibration set: 	C
#	Wavelength:				584.577535
#	Setpoint:				11127	
#
# ----------------------------------------------------------------------------

# import all the stuff from mvIMPACT Acquire into the current scope
from mvIMPACT import acquire
# import all the mvIMPACT Acquire related helper function such as 'conditionalSetProperty' into the current scope
# If you want to use this module in your code feel free to do so but make sure the 'Common' folder resides in a sub-folder of your project then
from mvIMPACT.Common import exampleHelper
 
# For systems with NO mvDisplay library support
import ctypes
import numpy as np
import datetime as dt
import xarray as xr

import matplotlib
import matplotlib.image

import serial
import serial.tools.list_ports as list_ports
from serial import Serial

from spectracular.fpi_driver import detectFPIDevices, createFPIDevice
import fpipy as fp

# ------------------------------------------------

# ledportstring = '/dev/ttyACM1'
ledportstring = 'COM10'

print('Trying to use ' + ledportstring + ' for LED control')
port = serial.Serial(ledportstring, 9600, timeout=0.5)

# Led Set C
# index	Npeaks	SP1	SP2	SP3	PeakWL1	PeakWL2	PeakWL3	Sinv11	Sinv12	Sinv13	Sinv21	Sinv22	Sinv23	Sinv31	Sinv32	Sinv33	FWHM1	FWHM2	FWHM3
# 54	1	11127	0	0	584.577535	0	0	0.702570403	2.016995336	-4.32210678	0	0	0	0	0	0	15.84827112	0	0

#C
print('LEDs on for set C')
input("Press to activate")
#led.L(0b000000001000000001000000001) 40201
port.flushOutput()
port.flushInput()
port.write(str.encode('L0x40201\r\n'))
port.flushOutput()
port.flushInput()
port.close()


# ------------------------------------------------

FPI_IDS = [
    # ( VID,   PID) (and the same in decimal)
    ('1FC9', '0083'), (8137, 131),
    ]
"""Known VID:PID pairs of FPI devices."""
FPI_HWIDS = [
    # Strings returned by read_hardware_id
	 'd02b012 af380065 5b5bbeab f50019c1'
]

print('Trying to create FPI device')
fpi = createFPIDevice(detectFPIDevices(FPI_IDS, FPI_HWIDS)[0].device)
print(fpi)

#C
# 54	1	11127	0	0	584.577535	0	0	0.702570403	2.016995336	-4.32210678	0	0	0	0	0	0	15.84827112	0	0

print('Setting MFPI setpoint')
fpi.set_setpoint(11127, wait=True)

input('Wait after setting setpoint')
fpi.close()

# ------------------------------------------------

 
devMgr = acquire.DeviceManager()
pDev = exampleHelper.getDeviceFromUserInput(devMgr)
if pDev == None:
    exampleHelper.requestENTERFromUser()
    sys.exit(-1)
pDev.open()

#
# Set system settings
#
#	RequestCount		10
#
ss = acquire.SystemSettings(pDev)

print("Old RequestCount:")
print(ss.requestCount.readS())

#
# Basic device settings
#
bdc = acquire.BasicDeviceSettings(pDev)
print("Old ImageRequestTimeout_ms:")
print(bdc.imageRequestTimeout_ms.readS())

#
# Set camera settings
#
#	AcquisitionMode		SingleFrame
#	TriggerSource		Line1
#	TriggerMode			Off
#
ac = acquire.AcquisitionControl(pDev)

print("Old AcquisitionMode:")
print(ac.acquisitionMode.readS())
print("New AcquisitionMode:")
ac.acquisitionMode.writeS("SingleFrame")
print(ac.acquisitionMode.readS())

print("Old TriggerSource:")
print(ac.triggerSource.readS())
# print("New TriggerSource:")
# ac.triggerSource.writeS("Software")
# print(ac.triggerSource.readS())

print("Old TriggerMode:")
print(ac.triggerMode.readS())
# print("New TriggerMode:")
# ac.triggerMode.writeS("On")
# print(ac.triggerMode.readS())

print("Old ExposureAuto:")
print(ac.exposureAuto.readS())
print("New ExposureAuto:")
ac.exposureAuto.writeS("Off")
print(ac.exposureAuto.readS())

ifc = acquire.ImageFormatControl(pDev)

print("Old pixelformat:")
print(ifc.pixelFormat.readS())
print("New pixelformat:")
ifc.pixelFormat.writeS("BayerGB12")
# ifc.pixelFormat.writeS("RGB8")
print(ifc.pixelFormat.readS())

print("Old pixelColorFilter:")
print(ifc.pixelColorFilter.readS())

imgp = acquire.ImageProcessing(pDev)

# "Auto" originally
print("Old colorProcessing:")
print(imgp.colorProcessing.readS())
imgp.colorProcessing.writeS("Raw")
print("New colorProcessing:")
print(imgp.colorProcessing.readS())


print("Old ExposureTime:")
print(ac.exposureTime.readS())
print("New ExposureTime:")
ac.exposureTime.writeS("150000")
print(ac.exposureTime.readS())

anlgc = acquire.AnalogControl(pDev)

print("Old BalanceWhiteAuto:")
print(anlgc.balanceWhiteAuto.readS())
print("New BalanceWhiteAuto:")
anlgc.balanceWhiteAuto.writeS("Off")
print(anlgc.balanceWhiteAuto.readS())

print("Old Gamma:")
print(anlgc.gamma.readS())
print("New Gamma:")
anlgc.gamma.writeS("1")
print(anlgc.gamma.readS())

print("Old Gain:")
print(anlgc.gain.readS())
print("New Gain:")
anlgc.gain.writeS("1.9382002601")
print(anlgc.gain.readS())

print("Old GainAuto:")
print(anlgc.gainAuto.readS())
print("New GainAuto:")
anlgc.gainAuto.writeS("Off")
print(anlgc.gainAuto.readS())

#
# Taking image
#
fi = acquire.FunctionInterface(pDev)

statistics = acquire.Statistics(pDev)

fi.imageRequestReset(0,0)

fi.imageRequestSingle()

exampleHelper.manuallyStartAcquisitionIfNeeded(pDev, fi)

# ac.triggerSoftware()

requestNr = fi.imageRequestWaitFor(20000)

# Add this from SingleCapture.cpp
exampleHelper.manuallyStopAcquisitionIfNeeded(pDev, fi)

if fi.isRequestNrValid(requestNr):

    print("Request number valid!")

    pRequest = fi.getRequest(requestNr)

    print("Print request: " + str(pRequest))
    print("Print request result: " + str(pRequest.requestResult))

    print("Print request result readS: " + pRequest.requestResult.readS())

    if pRequest.isOK:

        print("Request OK!")
        
        print("Info from " + pDev.serial.read() +
                    ": " + statistics.framesPerSecond.name() + ": " + statistics.framesPerSecond.readS() +
                    ", " + statistics.errorCount.name() + ": " + statistics.errorCount.readS() +
                    ", " + statistics.captureTime_s.name() + ": " + statistics.captureTime_s.readS())

        height = pRequest.imageHeight.read()
        width = pRequest.imageWidth.read()
        channelCount = pRequest.imageChannelCount.read()
        channelBitDepth = pRequest.imageChannelBitDepth.read()
        imageSize = pRequest.imageSize.read()
        
        print("Image height: " + str(height))
        print("Image width: " + str(width))
        print("Image channel count: " + str(channelCount))
        print("Image channel bit depth: " + str(channelBitDepth))
        print("Image size: " + str(imageSize))

        # For systems with NO mvDisplay library support
        cbuf = (ctypes.c_char * pRequest.imageSize.read()).from_address(int(pRequest.imageData.read()))
        #print(cbuf)

        # Handling in test_hsi6.py
        # self._pixel_format = "BayerGB12"
        # self._buffer_decoder = get_decoder(self._pixel_format)
        # data = self._buffer_decoder(cbuf, (height, width))

        data = np.frombuffer(
            cbuf,
            dtype=np.uint16
            ).reshape((height, width)).copy()

        print("Pixel data:")
        print(data)

        height, width = data.shape[0], data.shape[1]
        coords = {
            "x": ("x", np.arange(0, width) + 0.5),
            "y": ("y", np.arange(0, height) + 0.5),
            "timestamp": dt.datetime.today().timestamp(),
        }

        dims = ('y', 'x')

        # Replace these hard-coded values by reading from camera!
        coords['Gain'] = "1.9382002601"
        coords['ExposureTime'] = 150000
        coords['PixelFormat'] = "BayerGB12"
        coords['PixelColorFilter'] = "BayerGB"

        frame = xr.DataArray(
            data,
            name="frame",
            dims=dims,
            coords=coords,
            #attrs={
                #'valid_range': self._image_range,
                #}
        )

        print("Frame xarray:")
        print(frame)

        print("Save frame to netcdf:")
        frame.to_netcdf('testframe.nc')

        # Original code for shaping data
        # channelType = numpy.uint16 if channelBitDepth > 8 else numpy.uint8        
        # arr = numpy.fromstring(cbuf, dtype = channelType)
        # arr.shape = (height, width, channelCount)
        # print(arr)

        # print("Start saving PNG image...")
        # matplotlib.image.imsave('testimage.png', arr)

        #if channelCount == 1:
        #    img = Image.fromarray(arr)
        #else:
        #    img = Image.fromarray(arr, 'RGBA' if alpha else 'RGB')

    fi.imageRequestUnlock(requestNr)
    exampleHelper.manuallyStopAcquisitionIfNeeded(pDev, fi)
    fi.imageRequestReset(0,0)

else:
    # Please note that slow systems or interface technologies in combination with high resolution sensors
    # might need more time to transmit an image than the timeout value which has been passed to imageRequestWaitFor().
    # If this is the case simply wait multiple times OR increase the timeout(not recommended as usually not necessary
    # and potentially makes the capture thread less responsive) and rebuild this application.
    # Once the device is configured for triggered image acquisition and the timeout elapsed before
    # the device has been triggered this might happen as well.
    # The return code would be -2119(DEV_WAIT_FOR_REQUEST_FAILED) in that case, the documentation will provide
    # additional information under TDMR_ERROR in the interface reference.
    # If waiting with an infinite timeout(-1) it will be necessary to call 'imageRequestReset' from another thread
    # to force 'imageRequestWaitFor' to return when no data is coming from the device/can be captured.
    print("imageRequestWaitFor failed (" + str(requestNr) + ", " + acquire.ImpactAcquireException.getErrorCodeAsString(requestNr) + ")")
    
exampleHelper.manuallyStopAcquisitionIfNeeded(pDev, fi)
exampleHelper.requestENTERFromUser()


# ------------------------------------
# Turn off LED

print('Trying to use ' + ledportstring + ' for LED control')
port = serial.Serial(ledportstring, 9600, timeout=0.5)

print('LEDs turn off')
input("Press to activate")
port.flushOutput()
port.flushInput()
port.write(str.encode('L0x0\r\n'))
port.flushOutput()
port.flushInput()
port.close()

print('Finished!')

