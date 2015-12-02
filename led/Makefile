
###################################################
###  Project Specifics

PROJ = led


###################################################
###  Compiler / Assembler / Programmer Settings

# Flash Programmer
STFLASH = /usr/local/bin/st-flash

# GNU Toolchain
CC = arm-none-eabi-gcc
AS = arm-none-eabi-as
LD = arm-none-eabi-ld
OBJCOPY=arm-none-eabi-objcopy
OBJDUMP=arm-none-eabi-objdump

ASFLAGS = -mthumb -mcpu=cortex-m4


###################################################
###  Targets

all: $(PROJ).out $(PROJ).bin

%.out: %.o
	$(LD) -Ttext 0x0 -o $@ $<

%.bin: %.out
	$(OBJCOPY) -Obinary $< $@

%.o: %.s
	$(AS) $(ASFLAGS) $< -o $@

%.list: %.out
	$(OBJDUMP) -S $< > $@


###################################################
###  Special Targets

list: $(PROJ).list

# Flash the STM32F4
burn: all
	$(STFLASH) write $(PROJ).bin 0x8000000

clean:
	@echo "Cleaning..."
	@rm -f *.o *.bin *.out

.PHONY: all burn clean list
