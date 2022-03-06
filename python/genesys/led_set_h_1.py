
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

from LEDDriver import detect_LED_devices, LEDDriver, LEDException
from spectracular.fpi_driver import detectFPIDevices, createFPIDevice

import fpipy as fp
import fpipy.conventions as c
import xarray as xr
from tqdm.autonotebook import tqdm, trange

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
# ac.exposureTime.writeS("150000")
# ac.exposureTime.writeS("60000")
ac.exposureTime.writeS(str(exposureTime))
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

# -----------------------------------------
# Test
# -----------------------------------------

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
        print(arr)

        # print("Start saving PNG image...")
        # matplotlib.image.imsave('testimage.png', arr)

    fi.imageRequestUnlock(requestNr)
    
exampleHelper.manuallyStopAcquisitionIfNeeded(pDev, fi)


#----------------------------------------- 
#  LED driver
#-----------------------------------------

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

ledportstring = '/dev/ttyACM0'
print('Trying to use ' + ledportstring + ' for LED control')
# led = LEDDriver('/dev/ttyACM0')
# led = LEDDriver('COM10')
led = LEDDriver(ledportstring)
print(led)

led.open()

print('Turning off LEDs')
led.L(0)

#----------------------------------------- 
#  MFPI
#-----------------------------------------

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

# ------------------------------------------
#  camazing.pixelformats
# ------------------------------------------


class PixelFormatError(Exception):
    pass


def get_valid_range(pxformat):
    """Return the valid range of values for a given pixel format.

    Parameters
    ----------
    pxformat: str
        Pixel format as given by cameras GenICam PixelFormat feature.

    Returns
    ------
    np.array
        A vector of [min_value, max_value] with the same type as the decoded
        pixel format.
    """
    try:
        valid_range = _ranges[pxformat]
    except KeyError:
        raise PixelFormatError(f'No range found for the pixel format `{pxformat}')

    return valid_range


def get_decoder(pxformat):
    """Return a numpy decoder for a given GenICam pixel format.

    Parameters
    ----------
    pxformat: str
        Pixel format as given by cameras PixelFormat.

    Returns
    -------
    decoder: function
        Function for decoding a buffer
    """
    try:
        decoder = _decoders[pxformat]
    except KeyError:
        raise PixelFormatError(f'No decoder for the pixel format `{pxformat}`')

    return decoder


def decode_raw(dtype):
    """Decode raw buffer with a given bit depth."""
    def decode(buf, shape):
        return np.frombuffer(
            buf,
            dtype=dtype
            ).reshape(*shape).copy()
    return decode


def decode_RGB(bpp):
    """Decode RGB buffer with a given bit depth."""
    def decode(buf, shape):
        return np.frombuffer(
            buf,
            dtype=bpp,
            ).reshape(*shape, 3).copy()
    return decode


def decode_YCbCr422_8():
    """Decode YCbCr422 buffer with given bit depth."""
    raise NotImplementedError


_decoders = {
    'BayerRG8': decode_raw(np.uint8),
    'BayerGB8': decode_raw(np.uint8),
    'BayerGB12': decode_raw(np.uint16),
    'BayerRG12': decode_raw(np.uint16),
    'BayerRG16': decode_raw(np.uint16),
    'RGB8': decode_RGB(np.uint8),
    'Mono8': decode_raw(np.uint8),
    'Mono16': decode_raw(np.uint16),
    }

_ranges = {
    'BayerRG8': np.uint8([0, 255]),
    'BayerGB8': np.uint8([0, 255]),
    'BayerGB12': np.uint16([0, 4095]),
    'BayerRG12': np.uint16([0, 4095]),
    'BayerRG16': np.uint16([0, 65535]),
    'RGB8': np.uint8([0, 255]),
    'Mono8': np.uint8([0, 255]),
    'Mono16': np.uint16([0, 65535]),
    }

# ------------------------------------------
#  camazing.core
# ------------------------------------------


class DanielCamera:

    def __init__(self, pDev):
        self._meta = None
        self._pDev = pDev

    def __enter__(self):
        return self

    def __exit__(self, exception_type, exception_value, traceback):
        print("Exit DanielCamera")

    def _get_frame(self, timeout=1):
        """Helper function"""
		
        self._pixel_format = "BayerGB12"
        self._buffer_decoder = get_decoder(self._pixel_format)
        self._image_range = get_valid_range(self._pixel_format)
		
        # data = self._buffer_decoder(buffer.raw_buffer, (height, width))
		
		#------------------------
		# Take frame
		#------------------------

        self._fi = acquire.FunctionInterface(pDev)

        self._fi.imageRequestSingle()

        exampleHelper.manuallyStartAcquisitionIfNeeded(self._pDev, self._fi)

        requestNr = self._fi.imageRequestWaitFor(20000)

        exampleHelper.manuallyStopAcquisitionIfNeeded(self._pDev, self._fi)
        
        data = []
        
        if self._fi.isRequestNrValid(requestNr):
        
            print("Request number valid! " + str(requestNr))

            pRequest = self._fi.getRequest(requestNr)
            
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
                
                cbuf = (ctypes.c_char * pRequest.imageSize.read()).from_address(int(pRequest.imageData.read()))

                # Check if this is now correct buffer format!
                # Convert with numpy if needed
                data = self._buffer_decoder(cbuf, (height, width))
                print("Data from buffer_decoder()")
                print(data)

            self._fi.imageRequestUnlock(requestNr)

        else:
            print("imageRequestWaitFor failed (" + str(requestNr) + ", " + acquire.ImpactAcquireException.getErrorCodeAsString(requestNr) + ")")

        exampleHelper.manuallyStopAcquisitionIfNeeded(self._pDev, self._fi)

        return data

    def _get_frame_with_meta(self):
        """Fetch a frame and add metadata from the camera."""

        data = self._get_frame()
        print("Data from _get_frame(): ")
        print(data)

        height, width = data.shape[0], data.shape[1]
        coords = {
            "x": ("x", np.arange(0, width) + 0.5),
            "y": ("y", np.arange(0, height) + 0.5),
            "timestamp": dt.datetime.today().timestamp(),
        }

        if 'RGB' in self._pixel_format:
            dims = ('y', 'x', 'colour')
            coords['colour'] = list('RGB')
        elif 'YUV' in self._pixel_format:
            dims = ('y', 'x', 'colour')
            coords['colour'] = list('YUV')
        elif 'YCbCr' in self._pixel_format:
            dims = ('y', 'x', 'colour')
            coords['colour'] = ['Y', 'Cb', 'Cr']
        else:
            dims = ('y', 'x')

        # Keep some meta by default, if available
        # self._meta = []
            # for feature in ['Gain', 'ExposureTime', 'PixelFormat', 'PixelColorFilter']:
                # if feature in self._features:
                    # self._meta.append(feature)

        # Add metadata as coordinates
        # if self._meta:
            # coords.update({k: self._features[k].value for k in self._meta})

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
            attrs={
                'valid_range': self._image_range,
                }
        )

        return frame
		
    def get_frame(self):
        return self._get_frame_with_meta()
		


# ------------------------------------------
#  HSI
# ------------------------------------------

class CaptureException(Exception):
    pass


class HSI:
    """Hyperspectral imager"""

    def __init__(self, camera=None, fpi=None):
        self.camera = camera
        self.fpi = fpi
        self.dataset = None
        self.calibration_file = None

    def read_calibration_file(self, calibration_file):
        self.dataset = fp.io.read_calibration(calibration_file)
        self.calibration_file = calibration_file

    def take_dark_reference(self, number_of_frames=40, method="median"):
        self.read_calibration_file(self.calibration_file)

        # original_trigger_source = self.camera["TriggerSource"].value
        # self.camera["TriggerSource"].value = "Software"

        frames = []
        with self.camera:
            for idx in trange(0, number_of_frames):
                frame = self.camera.get_frame()
                frame.coords[c.image_index] = idx
                frames.append(frame)

        # self.camera["TriggerSource"].value = original_trigger_source

        dark = xr.concat(frames, dim=c.image_index)

        if method == "median":
            dark = dark.median(dim=c.image_index)
        elif method == "mean":
            dark = dark.mean(dim=c.image_index)
        else:
            raise ValueError("Unknown method: '" + method)

        self.dataset[c.dark_reference_data] = dark

        return dark

    def capture_cube(self, *, selectors=None):
        if selectors is None:
            dataset = self.dataset.copy()
        else:
            dataset = self.dataset.sel(**selectors).copy()

        frames = []
 #      if self.camera["TriggerSource"].value == "Software":
        with self.camera:
            for idx in tqdm(dataset[c.image_index].values):
                setpoint = dataset[c.setpoint_data].sel(
                    **{c.setpoint_coord: "SP1",
                       c.image_index: idx,
                       }).values
                self.fpi.set_setpoint(setpoint, wait=True)
                frame = self.camera.get_frame()
                frame.coords[c.image_index] = idx
                frames.append(frame)
#       else:
#            with self.camera:
#                self.create_fpi_taskfile(dataset)
#                self.camera["StrobeDuration"].value = \
#                    self.camera["ExposureTime"].value
#                self.fpi.run_taskfile()
#                for idx, setpoint in enumerate(tqdm(
#                        dataset.setpoint.sel(setpoint_index="SP1").values)):
#                    frame = self.camera.get_frame()
#                    frame.coords[c.image_index] = idx
#                    frames.append(frame)

        dataset[c.cfa_data] = xr.concat(frames, dim=c.image_index)
        return dataset

    def create_fpi_taskfile(dataset):
        raise NotImplementedError()


danielCam = DanielCamera(pDev)
print(danielCam)

hsi = HSI(danielCam, fpi)
print(hsi)
hsi.read_calibration_file('led_set_h_calib_1.txt')

input("Put the lens cap on")
hsi.take_dark_reference()
print(hsi.dataset.dark)

input("Take the lens cap off and set white reference")

print('Turning on LEDs')

# VNIR1 and VNIR2
#  
# 851.0365439
# 939.6902201
#
# 000001111000001111000001111
# * Reverse for LED control:
# 111100000111100000111100000
#
led.L(0b111100000111100000111100000)
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
	matplotlib.image.imsave('rad_' + wavelengthReplacedStr + 'nm_' + str(x) + '_exp_' + exposureTime + '.png', rad1, cmap='gray')

	white1 = whitedata[:,:,x]
	# matplotlib.image.imsave('white_' + wavelengthReplacedStr + 'nm_' + str(x) + '.png', white1, cmap='gray')
	
	ref1 = reflectdata[:,:,x]
	matplotlib.image.imsave('refl_' + wavelengthReplacedStr + 'nm_' + str(x) + '_exp_' + exposureTime + '.png', ref1, cmap='gray', vmin=0,vmax=1)



# import matplotlib.pyplot as plt
# plt.gray()

#
# Save raw images and demosaic images
#
# print('Start saving raw data')
# for x in range(1, 2):

	# Raw data values
	# dn1 = raw.dn.isel(index=x)
	# matplotlib.image.imsave('raw_' + str(x) + '.png', dn1)

	# Demosaic to get three colour channels
	# dm1 = fp.demosaic(dn1, 'BayerGB', 'bilinear')
	# dm1_red = dm1[:,:,0]
	# dm1_green = dm1[:,:,1]
	# dm1_blue = dm1[:,:,2]

	# matplotlib.image.imsave('raw_' + str(x) + '_demosaic_red.png', dm1_red)
	# matplotlib.image.imsave('raw_' + str(x) + '_demosaic_green.png', dm1_green)
	# matplotlib.image.imsave('raw_' + str(x) + '_demosaic_blue.png', dm1_blue)



# fi.acquisitionStart()
# self["TriggerSoftware"].execute()
# acquire.TriggerControl.triggerSoftware()
# fi.acquisitionStop()


