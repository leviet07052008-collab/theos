# Makefile cho Free Fire Menu + Antiban

export THEOS = /home/codespace/theos
export SDKVERSION = 16.5
export TARGET = iphone:clang:16.5:16.5

THEOS_PACKAGE_SOURCE = rootless
THEOS_NO_DEFAULTS = 0

ARCHS = arm64 arm64e

INSTALL_TARGET_PROCESSES = FreeFire

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = FFMenu

FFMenu_CCFLAGS = -std=c++17 -fno-rtti -DNDEBUG -Wall -fobjc-arc -Wno-deprecated-declarations
FFMenu_FRAMEWORKS = UIKit Foundation Security QuartzCore CoreGraphics
FFMenu_FILES = Tweak.xm Aniban.mm ImageDrawView.mm
FFMenu_CFLAGS = -fobjc-arc

include $(THEOS)/makefiles/tweak.mk