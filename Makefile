export ARCHS = arm64 arm64e
export TARGET = iphone:clang:latest:14.0
export THEOS = /home/codespace/theos
export THEOS_PACKAGE_SCHEME = rootless
export FINALPACKAGE = 1

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = FrogHack

FrogHack_FILES = Tweak.xm
FrogHack_CFLAGS = -fobjc-arc
FrogHack_FRAMEWORKS = UIKit Foundation CoreGraphics
FrogHack_LIBRARIES = substrate

include $(THEOS_MAKE_PATH)/tweak.mk