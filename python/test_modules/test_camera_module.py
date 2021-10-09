# ----------------------------------------------------------------------------
#	test_camera_module.py
#
#	Copyright 2021 Daniel Tisza
#	MIT License
#
#	Test creating camera module instance
#
# ----------------------------------------------------------------------------

from camazing import CameraList

cameras = CameraList()
print(cameras)

camera = cameras[0]
camera.initialize()


