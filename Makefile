ARCHS = arm64 arm64e
TARGET := iphone:clang:15.3.1
INSTALL_TARGET_PROCESSES = SpringBoard

THEOS_PACKAGE_SCHEME=rootless
THEOS_DEVICE_IP=10.0.0.114

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = UnicodeEscape15

${TWEAK_NAME}_FILES = Tweak.xm
${TWEAK_NAME}_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
