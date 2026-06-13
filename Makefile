export THEOS=/home/codespace/theos
export SDKVERSION=16.5
export TARGET=iphone:clang:16.5:16.5

THEOS_PACKAGE_SOURCE=rootless
THEOS_NO_DEFAULTS=0

ARCHS = arm64 arm64e

INSTALL_TARGET_PROCESSES = FreeFire

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = FFMenu

FFMenu_FILES = Tweak.xm
FFMenu_CFLAGS = -fobjc-arc -Wno-unused-function -Wno-deprecated-declarations
FFMenu_FRAMEWORKS = UIKit Foundation CoreGraphics QuartzCore
FFMenu_PRIVATE_FRAMEWORKS = GraphicsServices
FFMenu_LDFLAGS = -undefined dynamic_lookup

include $(THEOS)/makefiles/tweak.mk

clean::
	rm -rf .theos/ obj/ packages/ *.deb