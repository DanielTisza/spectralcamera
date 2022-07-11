# ----------------------------------------------------------------------------
#	save_single_rgb888.py
#
#	Copyright 2021 Daniel Tisza
#	MIT License
#
#	Acquiring single RGB888 image
#	with only camera module available
#   and drawing to display
#
#	Version 2022.07.11  22:01
# ----------------------------------------------------------------------------

from __future__ import print_function
import os
import platform
import sys

from mvIMPACT import acquire
from mvIMPACT.Common import exampleHelper

import ctypes
import numpy as np
import datetime as dt

import matplotlib

#from LEDDriver import detect_LED_devices, LEDDriver, LEDException
#from spectracular.fpi_driver import detectFPIDevices, createFPIDevice

import fpipy as fp
import fpipy.conventions as c
import xarray as xr
from tqdm.autonotebook import tqdm, trange
import pandas as pd
import time

# Argument count
argc = len(sys.argv)
print("Argument count: ", argc)

# Arguments passed
for i in range(1, argc):
    print(sys.argv[i], end = " ")
print("")

if argc == 1:
    exposureTime = "60000"
    print("No exposure time argument given! Using default 60000")
else:
    exposureTime = sys.argv[1]
    print("Exposure time given as argument: ", exposureTime)

print("Using exposure time: ", exposureTime)
print("Exposure time converted to string: ", str(exposureTime))


#----------------------------------------- 
#  Camera
#-----------------------------------------

devMgr = acquire.DeviceManager()
pDev = exampleHelper.getDeviceFromUserInput(devMgr)
if pDev == None:
    exampleHelper.requestENTERFromUser()
    sys.exit(-1)
pDev.open()


#
# Set camera settings
#
ac = acquire.AcquisitionControl(pDev)

# print("Old TriggerMode:")
# print(ac.triggerMode.readS())
# print("New TriggerMode:")
# ac.triggerMode.writeS("On")
# print(ac.triggerMode.readS())
 
# print("Old TriggerSource:")
# print(ac.triggerSource.readS())
# print("New TriggerSource:")
# ac.triggerSource.writeS("Software")
# print(ac.triggerSource.readS())

print("Old ExposureAuto:")
print(ac.exposureAuto.readS())
print("New ExposureAuto:")
ac.exposureAuto.writeS("Off")
print(ac.exposureAuto.readS())

ifc = acquire.ImageFormatControl(pDev)

print("Old pixelformat:")
print(ifc.pixelFormat.readS())
print("New pixelformat:")
# ifc.pixelFormat.writeS("BayerGB12")
ifc.pixelFormat.writeS("RGB8")
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

# -----------------------------------------
# Test
# -----------------------------------------

print('')
print('Capturing single image')

print('')

print("Setting normal exposure")
print("Old ExposureTime:")
print(ac.exposureTime.readS())
print("New ExposureTime:")
# ac.exposureTime.writeS("150000")
# ac.exposureTime.writeS("60000")
ac.exposureTime.writeS(str(exposureTime))
print(ac.exposureTime.readS())

print('')

#
# Taking image
#
fi = acquire.FunctionInterface(pDev) 
fi.imageRequestSingle()
exampleHelper.manuallyStartAcquisitionIfNeeded(pDev, fi)
requestNr = fi.imageRequestWaitFor(10000)
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

        print(cbuf)

        channelType = np.uint16 if channelBitDepth > 8 else np.uint8
        
        arr = np.fromstring(cbuf, dtype = channelType)
        
        arr.shape = (height, width, channelCount)

        print(' ')
        print('arr:')
        print(arr)

        # Adjust pixel values to 0.0 - 1.0 range
        dmMin = np.min(arr)
        dmMax = np.max(arr)
        dmClamped = (arr - dmMin) / (dmMax - dmMin)

        print(' ')
        print('dmClamped:')
        print(dmClamped)

        strFilename = 'rgb888_' + '_exp_' + exposureTime + '.png'
        print(' ')
        print('Saving image: ' + strFilename)
        matplotlib.image.imsave(strFilename, dmClamped)

        # Draw to screen also

        print(' ')
        dmClamped31 = dmClamped * 31
        print(dmClamped31)


        strFilenameDat = 'rgb888_' + '_exp_' + exposureTime + '.dat'
        print(' ')
        print('Saving image: ' + strFilenameDat)
        f = open(strFilenameDat, 'wb')

        rowcount = 0

        for row in dmClamped:

            colcount = 0

            for col in row:

                #print(col)

                redbyte = col[0] * 31
                greenbyte = col[1] * 31
                bluebyte = col[2] * 31

                if (rowcount < 1024):
                    if (colcount < 1280):
                        f.write(redbyte.astype(np.uint8))
                        f.write(greenbyte.astype(np.uint8))
                        f.write(bluebyte.astype(np.uint8))

                colcount = colcount + 1

            rowcount = rowcount + 1

            if (rowcount > 1024):
                break

        f.close()

    fi.imageRequestUnlock(requestNr)
    
exampleHelper.manuallyStopAcquisitionIfNeeded(pDev, fi)

print('')

