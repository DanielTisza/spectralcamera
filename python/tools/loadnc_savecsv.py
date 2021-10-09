# ----------------------------------------------------------------------------
#	loadnc_savecsv.py
#
#	Copyright 2021 Daniel Tisza
#	MIT License
#
#	Load frame from NETCDF file and save to CSV file using Pandas
#
# ----------------------------------------------------------------------------

import xarray as xr
import pandas as pd

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
# Remove unnecessary coordinates
# 
frameresetcoords = frame.reset_coords(names=None,drop=True)

#
# Convert xarray frame to pandas dataframe
#
print()
print('Convert to dataframe')
#df = frame.to_dataframe()
df = frameresetcoords.to_dataframe()
print(df)
#df = dn1.to_dataframe()


#
# Save pandas dataframe to CSV
#
print()
print('Save to CSV')
#df.to_csv('testframe.csv')
df.to_csv('testframe.csv', index=False)

