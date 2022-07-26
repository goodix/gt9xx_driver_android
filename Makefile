#
# Makefile for the Goodix gt9xx touchscreen driver.
#
#subdir-ccflags-y += -DDEBUG
obj-$(CONFIG_TOUCHSCREEN_GT9XX)	+= gt9xx_core.o
gt9xx_core-y := gt9xx.o gt9xx_update.o goodix_tool.o



