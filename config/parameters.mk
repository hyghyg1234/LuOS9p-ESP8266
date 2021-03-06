# Parameters for the esp-open-rtos make process
#
# You can edit this file to change parameters, but a better option is
# to create a local.mk file and add overrides there. The local.mk file
# can be in the root directory, or the program directory alongside the
# Makefile, or both.
#
-include $(ROOT)local.mk
-include local.mk

PLATFORM=esp8266

# Flash size in megabits
# Valid values are same as for esptool.py - 2,4,8,16,32
FLASH_SIZE ?= 32

# Flash mode, valid values are same as for esptool.py - qio,qout,dio.dout
FLASH_MODE ?= dio

# Flash speed in MHz, valid values are same as for esptool.py - 80, 40, 26, 20
FLASH_SPEED ?= 40

# Output directories to store intermediate compiled files
# relative to the program directory
#BUILD_DIR ?= $(ROOT)platform/$(PLATFORM)/build/
#FIRMWARE_DIR ?= $(ROOT)platform/$(PLATFORM)/firmware/
BUILD_DIR ?= $(ROOT)bld/
FIRMWARE_DIR ?= $(ROOT)bld/firmware/

# esptool.py from https://github.com/themadinventor/esptool
ESPTOOL ?= esptool.py
# serial port settings for esptool.py
ESPPORT ?= /dev/ttyUSB0
ESPBAUD ?= 115200

# firmware tool arguments
ESPTOOL_ARGS=-fs $(FLASH_SIZE)m -fm $(FLASH_MODE) -ff $(FLASH_SPEED)m


# set this to 0 if you don't need floating point support in printf/scanf
# this will save approx 14.5KB flash space and 448 bytes of statically allocated
# data RAM
#
# NB: Setting the value to 0 requires a recent esptool.py (Feb 2016 / commit ebf02c9)
PRINTF_SCANF_FLOAT_SUPPORT ?= 1

FLAVOR ?= release # or debug

# Compiler names, etc. assume gdb
CROSS ?= xtensa-lx106-elf-

# Path to the filteroutput.py tool
FILTEROUTPUT ?= $(ROOT)/utils/filteroutput.py

AR = $(CROSS)ar
CC = $(CROSS)gcc
CPP = $(CROSS)cpp
LD = $(CROSS)gcc
NM = $(CROSS)nm
C++ = $(CROSS)g++
SIZE = $(CROSS)size
OBJCOPY = $(CROSS)objcopy
OBJDUMP = $(CROSS)objdump

# Source components to compile and link. Each of these are subdirectories
# of the root, with a 'component.mk' file.
COMPONENTS     ?= $(EXTRA_COMPONENTS) \
		    $(ROOT)FreeRTOS \
		    $(ROOT)sys pthread Lua \
		    $(ROOT)modules/core \
		    $(ROOT)modules/lwip \
		    $(ROOT)modules/open_esplibs \
		    $(ROOT)modules/ssd1306_2 \
		    $(ROOT)modules/fonts \
		    $(ROOT)modules/pca9685 \
		    $(ROOT)modules/pcf8591 \
		    $(ROOT)modules/pcf8574 \
		    $(ROOT)modules/mbedtls \
		    $(ROOT)modules/lpeg \
		    $(ROOT)sys/spiffs \
		    $(ROOT)modules/luadata \
		    $(ROOT)modules/luadata_io \
		    $(ROOT)modules/styx \
		    $(ROOT)modules/pid \
		    $(ROOT)modules/pnmio \


#		    $(ROOT)modules/9p/curie \
#		    $(ROOT)modules/9p/duat \

#		    $(ROOT)modules/mqtt \
#		    $(ROOT)modules/sjson \

#		    $(ROOT)modules/mdns \

#		    $(ROOT)modules/sjson \
#		    $(ROOT)modules/luacurl \
#		    $(ROOT)modules/cURLv3 \
#		    $(ROOT)modules/smart \
#		    $(ROOT)modules/mqtt \

#		    $(ROOT)modules/dhcpserver \

#		    $(ROOT)modules/libesphttpd \

#		    $(ROOT)modules/rboot-ota \


#		    $(ROOT)modules/httpd \
#		    $(ROOT)modules/ssd1306 \
#		    $(ROOT)modules/i2c2 \


#		    $(ROOT)platform/$(PLATFORM)/platform \
#		    $(ROOT)platform/$(PLATFORM)/i2c \
#		    $(ROOT)platform/$(PLATFORM)/u8g2/cppsrc \
#		    $(ROOT)platform/$(PLATFORM)/arduino \
#		    $(HOME)/esp-open-rtos/extras/ssd1306 \
#		    $(HOME)/esp-open-rtos/extras/i2c \

#		    $(HOME)/esp-open-rtos/open_esplibs \
#		    $(HOME)/esp-open-rtos/lwip \
#		    $(HOME)/esp-open-rtos/core \


#		    platform/$(PLATFORM)/open_esplibs \
#		    platform/$(PLATFORM)/lwip \
#		    platform/$(PLATFORM)/core \
#		    platform/$(PLATFORM)//u8g2/csrc \


# binary esp-iot-rtos SDK libraries to link. These are pre-processed prior to linking.
SDK_LIBS ?= main net80211 phy pp wpa

# open source libraries linked in
LIBS ?= hal gcc c m esp-gdbstub

# set to 0 if you want to use the toolchain libc instead of esp-open-rtos newlib
OWN_LIBC ?= 1

# Note: you will need a recent esp
ENTRY_SYMBOL ?= call_user_start

# Set this to zero if you don't want individual function & data sections
# (some code may be slightly slower, linking will be slighty slower,
# but compiled code size will come down a small amount.)
SPLIT_SECTIONS ?= 1

# Set this to 1 to have all compiler warnings treated as errors (and stop the
# build).  This is recommended whenever you are working on code which will be
# submitted back to the main project, as all submitted code will be expected to
# compile without warnings to be accepted.
WARNINGS_AS_ERRORS ?= 0

# Common flags for both C & C++_
C_CXX_FLAGS ?= -Wall -Wl,-EL -nostdlib $(EXTRA_C_CXX_FLAGS)
# Flags for C only
CFLAGS		?= $(C_CXX_FLAGS) -std=gnu99 -mlongcalls -mtext-section-literals -Wno-array-bounds $(EXTRA_CFLAGS) -D__XMK__ -fno-builtin
# Flags for C++ only
CXXFLAGS	?= $(C_CXX_FLAGS) -fno-exceptions -fno-rtti $(EXTRA_CXXFLAGS)

# these aren't all technically preprocesor args, but used by all 3 of C, C++, assembler
CPPFLAGS	+= -mlongcalls -mtext-section-literals

include $(ROOT)config/config.mk
#include $(ROOT)platform/$(PLATFORM)/config.mk
EXTRA_LDFLAGS   = -L$(ROOT)modules/esp-gdbstub/lib 
#-Wl,--wrap=malloc -Wl,--wrap=calloc -Wl,--wrap=realloc -Wl,--wrap=free
LDFLAGS		= -nostdlib -L$(BUILD_DIR)sdklib -L$(ROOT)lib -u $(ENTRY_SYMBOL) -Wl,--no-check-sections \
	    -Wl,-Map=$(BUILD_DIR)$(PROGRAM).map $(EXTRA_LDFLAGS)

CFLAGS      += -DUSE_CUSTOM_HEAP=0 -I$(ROOT)Lua/src -I$(ROOT)FreeRTOS/Source/include \
	    -I$(ROOT)include/platform/esp8266/espressif -I$(ROOT)include/platform/esp8266/espressif/esp8266 \
	    -I$(ROOT)modules/lwip/lwip/espressif/include \
	    -I$(ROOT)modules/core/include/esp \
	    -I$(ROOT)modules/core/include \
	    -I$(ROOT)sys \
	    -I$(ROOT)modules/esp-gdbstub/include 

LINKER_SCRIPTS += $(ROOT)config/ld/program.ld $(ROOT)config/ld/rom.ld

ifeq ($(WARNINGS_AS_ERRORS),1)
    C_CXX_FLAGS += -Werror
endif

ifeq ($(SPLIT_SECTIONS),1)
  C_CXX_FLAGS += -ffunction-sections -fdata-sections
  LDFLAGS += -Wl,-gc-sections
endif

ifeq ($(FLAVOR),debug)
    C_CXX_FLAGS += -O2
    LDFLAGS += -O2
else ifeq ($(FLAVOR),sdklike)
    # These are flags intended to produce object code as similar as possible to
    # the output of the compiler used to build the SDK libs (for comparison of
    # disassemblies when coding replacement routines).  It is not normally
    # intended to be used otherwise.
    CFLAGS += \
	    -O2 -Os \
	    -fno-inline -fno-ipa-cp -fno-toplevel-reorder -fno-caller-saves -fconserve-stack
#	    -g -Og -ggdb -DDEBUG_ESP_PORT=Serial \

    LDFLAGS += -O2

#-Og -ggdb -DDEBUG_ESP_PORT=Serial
#-O2
else
    C_CXX_FLAGS += -g -O2
    LDFLAGS += -O2
endif

GITSHORTREV=\"$(shell cd $(ROOT); git rev-parse --short -q HEAD 2> /dev/null)\"
ifeq ($(GITSHORTREV),\"\")
  GITSHORTREV="\"(nogit)\"" # (same length as a short git hash)
endif
CPPFLAGS += -DGITSHORTREV=$(GITSHORTREV)

# rboot firmware binary paths for flashing
RBOOT_BIN = $(FIRMWARE_DIR)/rboot.bin
RBOOT_PREBUILT_BIN = $(ROOT)platform/$(PLATFORM)/bootloader/firmware_prebuilt/rboot.bin
RBOOT_CONF = $(ROOT)platform/$(PLATFORM)/bootloader/firmware_prebuilt/blank_config.bin

# if a custom bootloader hasn't been compiled, use the
# prebuilt binary from the source tree
ifeq (,$(wildcard $(RBOOT_BIN)))
RBOOT_BIN=$(RBOOT_PREBUILT_BIN)
#echo "use prebuild bootloader"
else
#echo "use custom bootloader"
endif
