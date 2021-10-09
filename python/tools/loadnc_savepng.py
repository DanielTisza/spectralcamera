# ----------------------------------------------------------------------------
#	loadnc_savepng.py
#
#	Copyright 2021 Daniel Tisza
#	MIT License
#
#	Load frame from NETCDF file and save as PNG
#
# ----------------------------------------------------------------------------

import xarray as xr

import matplotlib
import matplotlib.image
import matplotlib.pyplot as plt

import fpipy as fp

print("Load frame from netcdf:")
dataset = xr.open_dataset('testframe.nc')

print("Print dataset:")
print(dataset)

frame = dataset['frame']

print("Print frame:")
print(frame)

print("Print frame data:")
framedata = frame.data
print(framedata)

plt.gray()

#
# Save raw images and demosaic images
#
print('Start saving raw data')

# Save raw data values converted to grayscale
# dn1 = raw.dn.isel(index=x)
dn1 = frame.data
matplotlib.image.imsave('raw.png', dn1)

# Demosaic to get three colour channels
dm1 = fp.demosaic(frame, 'BayerGB', 'bilinear')

dm1_red = dm1[:,:,0]
dm1_green = dm1[:,:,1]
dm1_blue = dm1[:,:,2]

# Save colour channel images
print('Start saving demosaic red data')
matplotlib.image.imsave('raw_demosaic_red.png', dm1_red)

print('Start saving demosaic green data')
matplotlib.image.imsave('raw_demosaic_green.png', dm1_green)

print('Start saving demosaic blue data')
matplotlib.image.imsave('raw_demosaic_blue.png', dm1_blue)




























