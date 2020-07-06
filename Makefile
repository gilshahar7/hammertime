FINALPACKAGE = 1
INSTALL_TARGET_PROCESSES = SpringBoard
ARCHS = arm64 arm64e
include $(THEOS)/makefiles/common.mk

TWEAK_NAME = HammerTime

HammerTime_FILES = Tweak.xm
HammerTime_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
