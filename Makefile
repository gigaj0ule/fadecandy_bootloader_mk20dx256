#######################################################
# Environment setup

# toolchain
CC = arm-none-eabi-gcc
CXX = arm-none-eabi-g++
OBJCOPY = arm-none-eabi-objcopy
OBJDUMP = arm-none-eabi-objdump
SIZE = arm-none-eabi-size

#######################################################

# The name of your project (used to name the compiled .hex file)
TARGET = fc-boot


# Headers
INCLUDES = -I.


# CPPFLAGS = compiler options for C and C++.
# More aggressive size optimizations here than in the normal firmware!
CPPFLAGS = -Wall -Wno-sign-compare -Wno-strict-aliasing -g -Os \
	-ffunction-sections -fdata-sections -nostdlib \
	-D__MK20DX256__ -mcpu=cortex-m4 -mthumb -nostdlib -MMD $(OPTIONS) $(INCLUDES) \
	-DF_CPU=48000000


# compiler options for C++ only
CXXFLAGS = -std=gnu++14 -felide-constructors -fno-exceptions -fno-rtti


# compiler options for C only
CFLAGS =


# linker script
LDSCRIPT = mk20dx256.ld


# linker options
LDFLAGS = -Os -Wl,--gc-sections -mcpu=cortex-m4 -mthumb \
	-ffunction-sections -fdata-sections -nostdlib -T$(LDSCRIPT)


# additional libraries to link
LIBS = -lm


# automatically create lists of the sources and objects
C_FILES := $(wildcard *.c)
CPP_FILES := $(wildcard *.cpp)
OBJS := $(C_FILES:.c=.o) $(CPP_FILES:.cpp=.o)


# the actual makefile rules (all .o files built by GNU make's default implicit rules)
all: $(TARGET).hex $(TARGET).bin size

# Compile c files
%.o: %.c
	$(CC) $(CPPFLAGS) $(CFLAGS) -c $< -o $@ 

# Compile cpp files
%.o: %.cpp
	$(CC) $(CPPFLAGS) $(CXXFLAGS) -c $< -o $@ 

# Link files
$(TARGET).elf: $(OBJS) 
	$(CC) -o $@ $^ $(LDFLAGS) 

# Generate iHex binary
%.hex: %.elf
	$(OBJCOPY) -O ihex $< $@
#second command..	

# Generate byte stream binary
%.bin: %.elf
	$(OBJCOPY) -O binary $< $@

# compiler generated dependency info
-include $(OBJS:.o=.d)

clean:
	rm -f *.d *.o $(TARGET).elf $(TARGET).hex $(TARGET).bin

# Install with OpenOCD. (No code protection!)
install: $(TARGET).hex
	openocd -f openocd.cfg -c "program $(TARGET).hex verify reset"

objdump: $(TARGET).elf
	$(OBJDUMP) -d $<

size: $(TARGET).elf
	$(SIZE) $<

.PHONY: all clean install objdump size
