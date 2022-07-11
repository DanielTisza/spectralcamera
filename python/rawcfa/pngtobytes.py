# ----------------------------------------------------------------------------
#	pngtobytes.py
#
#	Copyright 2021 Daniel Tisza
#	MIT License
#
#	Read PNG file and save as ARGB bytes
#
#	Version 2022.07.10  16:42
# ----------------------------------------------------------------------------

from __future__ import print_function
import os
import platform
import sys
import io

from mvIMPACT import acquire
from mvIMPACT.Common import exampleHelper

import ctypes
import numpy as np
import matplotlib
import xarray as xr

from matplotlib import image

import io

rawdemosaic = image.imread("rawdemosaic_0_exp_60000_ledset_1.png")

print(rawdemosaic)

print('')

f = open('test.dat', 'wb')

for row in rawdemosaic:
	for col in row:
		#print(col)
		redbyte = col[0] # * 31
		greenbyte = col[1] # * 31
		bluebyte = col[2] # * 31

		f.write(redbyte.astype(np.uint8))
		f.write(greenbyte.astype(np.uint8))
		f.write(bluebyte.astype(np.uint8))

print('')

#red = rawdemosaic[0,0,0]
#green = rawdemosaic[0,0,1]
#blue = rawdemosaic[0,0,2]
#alpha = rawdemosaic[0,0,3]

#print(red)
#print(green)
#print(blue)
#print(alpha)

#print('')

#redbyte = red * 31
#greenbyte = green * 31
#bluebyte = blue * 31
#alphabyte = 1

#print(redbyte)
#print(greenbyte)
#print(bluebyte)
#print(alphabyte)

print('')

#print(type(redbyte))

print('')

f.close()
