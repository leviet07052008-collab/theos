TARGET = iphone:clang:latest:11.0
ARCHS = arm64 arm64e
INSTALL_TARGET_PROCESSES = FreeFire

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = FrogHack
FrogHack_FILES = Tweak.xm
FrogHack_FRAMEWORKS = UIKit Foundation CoreGraphics
FrogHack_CFLAGS = -fobjc-arc -w

include $(THEOS_MAKE_PATH)/tweak.mk