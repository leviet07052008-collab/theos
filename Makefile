export ARCHS = arm64 arm64e
export TARGET = iphone:clang:latest:14.0
export THEOS = /opt/theos
export THEOS_PACKAGE_SCHEME = rootless

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = FrogHack
FrogHack_FILES = Tweak.xm
FrogHack_CFLAGS = -fobjc-arc
FrogHack_FRAMEWORKS = UIKit Foundation CoreGraphics
FrogHack_LIBRARIES = substrate

FrogHack_BUNDLE = 1
FrogHack_BUNDLE_FILTER = com.dts.freefireth

include $(THEOS_MAKE_PATH)/tweak.mk