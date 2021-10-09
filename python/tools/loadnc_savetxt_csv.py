# ----------------------------------------------------------------------------
#	loadnc_savetxt_csv.py
#
#	Copyright 2021 Daniel Tisza
#	MIT License
#
#	Load frame from NETCDF file and save to CSV file using Numpy
#
# ----------------------------------------------------------------------------

import xarray as xr
import numpy as np

import fpipy as fp

#
# Load dataset from netcdf
#
print("Load frame from netcdf:")
dataset = xr.open_dataset('testframe.nc')

print()
print("Print dataset:")
print(dataset)
# <xarray.Dataset>

#
# Extract 'frame' from dataset
#
print()
print("Print frame:")
frame = dataset['frame']
print(frame)
# <xarray.DataArray 'frame' (y: 1944, x: 2592)>
# [5038848 values with dtype=int16]

#
# Extract framedata from 'frame'
#
print()
print("Print frame data:")
framedata = frame.data
print(framedata)

#
# Save raw image to csv
#
print()
print('Start saving raw data')

# Save raw data values converted to grayscale
dn1 = frame.data
# matplotlib.image.imsave('raw.png', dn1)
print(dn1)

#
# Save to CSV
#
print()
print('Save to CSV')
np.savetxt("testsavetext.csv",dn1,fmt='%d',delimiter=',')

