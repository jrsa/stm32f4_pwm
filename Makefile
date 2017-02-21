#  Project Name
PROJECT=pwmtest

#  Type of CPU/MCU in target hardware
CPU=cortex-m4
CHIP=STM32F401xE

#  Define the external crystal (HSE) frequency used as the PLL clock, in Hz
HSE_VALUE=8000000

#  Build the list of object files needed.  All object files will be built in
#  the working directory, not the source directories.
#
#  You will need as a minimum your $(PROJECT).o file and the startup_stm32f4xx.o
#  object file.  Depending on where your code sets up the MCU's clocks and
#  PLL, you may also need some kind of initialization file, typically
#  system_stm32f4xx.o.  Finally, you will need whatever STMicros' standard
#  peripherals objects you use, such as stm32f4xx_gpio.o.
OBJECTS		=  main.o
OBJECTS		+= system.o
OBJECTS		+= startup_stm32f401xe.o
	      
#  Select the toolchain by providing a path to the top level
#  directory; this will be the folder that holds the
#  arm-none-eabi subfolders.
TOOLPATH = /usr/local

#  Provide a base path to the STM32F4 firmware release folder.
#  This is the folder containing all of the original STMicros
#  examples, libraries, and includes for the STM32F4 Discovery
#  board.
STM32_ROOT = /Users/jrsa/code/stm32/STM32Cube_FW_F4_V1.13.0

#
#  Select the target type.  This is typically arm-none-eabi.
#  If your toolchain supports other targets, those target
#  folders should be at the same level in the toolchain as
#  the arm-none-eabi folders.
TARGETTYPE = arm-none-eabi

#  Describe the various include and source directories needed.
#  These usually point to files from whatever distribution
#  you are using (such as STM32F4 Discovery).  This can also
#  include paths to any needed GCC includes or libraries.
# INCDIRS  = -I$(GCC_INC)
INCDIRS = "-I$(STM32_ROOT)/Drivers/CMSIS/Device/ST/STM32F4xx/Include"
INCDIRS += "-I$(STM32_ROOT)/Drivers/CMSIS/Include"
INCDIRS += "-I$(STM32_ROOT)/Drivers/BSP/STM32F4xx-Nucleo"
INCDIRS += "-I."

# Name and path to the linker script
LSCRIPT = STM32F401CE_FLASH.ld


OPTIMIZATION = 0
DEBUG = -g

#  List the directories to be searched for libraries during linking.
#  Optionally, list archives (libxxx.a) to be included during linking. 
LIBDIRS  = -L"$(TOOLPATH)/$(TARGETTYPE)/lib"
LIBS = -lc

#  Compiler options
GCFLAGS = -std=c99 -Wall -fno-common -mcpu=$(CPU) -mthumb -O$(OPTIMIZATION) $(DEBUG)
GCFLAGS += $(INCDIRS)
GCFLAGS += -D__STARTUP_CLEAR_BSS
GCFLAGS += -DHSE_VALUE=$(HSE_VALUE)
GCFLAGS += -D$(CHIP)


#  Linker options
LDFLAGS  = -std=c99 -mcpu=cortex-m4 -mlittle-endian -mthumb -D$(CHIP) -T$(LSCRIPT) -Wl,--gc-sections
# LDFLAGS += --cref
LDFLAGS += $(LIBDIRS)
LDFLAGS += $(LIBS)


#  Assembler options
ASLISTING = -alhs
ASFLAGS = $(ASLISTING) -mcpu=$(CPU)


#  Tools paths
#
#  Define an explicit path to the GNU tools used by make.
#  If you are ABSOLUTELY sure that your PATH variable is
#  set properly, you can remove the BINDIR variable.
#
BINDIR = $(TOOLPATH)/bin

CC = $(BINDIR)/arm-none-eabi-gcc
AS = $(BINDIR)/arm-none-eabi-as
AR = $(BINDIR)/arm-none-eabi-ar
LD = $(BINDIR)/arm-none-eabi-gcc
OBJCOPY = $(BINDIR)/arm-none-eabi-objcopy
SIZE = $(BINDIR)/arm-none-eabi-size
OBJDUMP = $(BINDIR)/arm-none-eabi-objdump

#  Define a command for removing folders and files during clean.  The
#  simplest such command is Linux' rm with the -f option.  You can find
#  suitable versions of rm on the web.
REMOVE = rm -f

#########################################################################

all:: $(PROJECT).hex $(PROJECT).bin stats dump

$(PROJECT).bin: $(PROJECT).elf
	$(OBJCOPY) -O binary -j .text -j .data $(PROJECT).elf $(PROJECT).bin

$(PROJECT).hex: $(PROJECT).elf
	$(OBJCOPY) -R .stack -O ihex $(PROJECT).elf $(PROJECT).hex

#  Linker invocation
#  Uncomment one of the two lines that begin $(LD).
#  If you use the longer line, any errors will be reformatted for use by the Visual Studio
#  Intellisense application, so you can double-click on the error and go directly to the source
#  line.  If you use the shorter line, you get the regular GCC error format.
$(PROJECT).elf: $(OBJECTS)
#	$(LD) $(OBJECTS) $(LDFLAGS) -o $(PROJECT).elf 2>&1 | sed -e "s/\(\w\+\):\([ 0-9]\+\):/\1(\2):/"
	$(LD) $(OBJECTS) $(LDFLAGS) -o $(PROJECT).elf

stats: $(PROJECT).elf
	$(SIZE) $(PROJECT).elf
	
dump: $(PROJECT).elf
	$(OBJDUMP) -h $(PROJECT).elf	

clean:
	$(REMOVE) *.o
	$(REMOVE) $(PROJECT).hex
	$(REMOVE) $(PROJECT).elf
	$(REMOVE) $(PROJECT).map
	$(REMOVE) $(PROJECT).bin
	$(REMOVE) *.lst

#  The toolvers target provides a sanity check, so you can determine
#  exactly which version of each tool will be used when you build.
#  If you use this target, make will display the first line of each
#  tool invocation.
#  To use this feature, enter from the command-line:
#    make -f $(PROJECT).mak toolvers
toolvers:
	$(CC) --version | sed q
	$(AS) --version | sed q
	$(LD) --version | sed q
	$(AR) --version | sed q
	$(OBJCOPY) --version | sed q
	$(SIZE) --version | sed q
	$(OBJDUMP) --version | sed q
	
#########################################################################
#  Default rules to compile .c and .cpp file to .o
#  and assemble .s files to .o

#  There are two options for compiling .c files to .o; uncomment only one.
#  The shorter option is suitable for making from the command-line.
#  The option with the sed script on the end is used if you want to
#  compile from Visual Studio; the sed script reformats error messages
#  so Visual Studio's IntelliSense feature can track back to the source
#  file with the error.
.c.o :
	@echo Compiling $<, writing to $@...
	$(CC) $(GCFLAGS) -c $< -o $@
# 	$(CC) $(GCFLAGS) -c $< 2>&1 | sed -e 's/\(\w\+\):\([ 0-9]\+\):/\1(\2):/'

.cpp.o :
	@echo Compiling $<, writing to $@...
	$(CC) $(GCFLAGS) -c $<

.s.o :
	@echo Assembling $<, writing to $@...
	$(AS) $(ASFLAGS) -o $@ $<  > $(basename $@).lst

#########################################################################
