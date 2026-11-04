TARGET = iphone:clang:latest:14.0
ARCHS = arm64

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = 8ball
8ball_FILES = Tweak.xm
8ball_CFLAGS = -fobjc-arc -Wno-everything
8ball_LDFLAGS = -lstdc++ -framework UIKit

include $(THEOS_MAKE_PATH)/tweak.mk
