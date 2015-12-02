@@ led.asm
@@
@@ Blink an LED on the ST stm32f4 ARM Cortex-M4 board.
@@ Originally written by Frank Sergeant (for a different chip/board)
@@

@@ Directives
        .text
        .syntax unified
        .thumb
        .global _start
        .type start, %function

@@ Named Constants
        .equ CLOCK_FREQ      , 8000000                   @ 8 Mhz clock

        .equ PERIPH_BASE     , 0x40000000
        .equ AHB1PERIPH_BASE , PERIPH_BASE + 0x00020000
        .equ RCC_BASE        , AHB1PERIPH_BASE + 0x3800
        .equ RCC_AHB1ENR     , RCC_BASE + 0x0030
        .equ RCC_AHB1ENR_A   , 0

        .equ GPIOA_BASE      , AHB1PERIPH_BASE + 0x0000
        .equ GPIOA_MODER     , GPIOA_BASE + 0x0000
        .equ GPIOx_PIN       , 3

        .equ GPIOA_ODR       , GPIOA_BASE + 0x0014
        .equ GPIO_FREQ       , 1                        @ 1 pulse / s
        .equ GPIO_DELAY      , GPIO_FREQ*CLOCK_FREQ/2   @ period split evenly
                                                        @   into on/off

        .equ STACKINIT       , 0x20005000


@@ start of program region
_start:

        .word STACKINIT          @ initial stack pointer value
        .word start              @ reset vector

        .word _nmi_handler  + 1  @ all following handlers point to the loop at end
        .word _hard_fault   + 1  @   of file
        .word _memory_fault + 1
        .word _bus_fault    + 1
        .word _usage_fault  + 1

@@ starting point for the reset handler
start:

        @ Enable the Port A peripheral clock by setting bit 3
        @ see stm32f4_ref pg. 180
        ldr r7, = RCC_AHB1ENR     @ r7 <- address RCC_AHB1ENR
        ldr r6, [r7]              @ r6 <- contents of RCC_AHB1ENR
        orr r6, 1<<RCC_AHB1ENR_A  @ set r6 bit corresp. to our port
        str r6, [r7]

        @ Set the mode bit for [port A, pin GPIOx_PIN] so it behaves as a
        @ general purpose push-pull output. See stm32f4_ref pg. 282.
        ldr r6, = GPIOA_MODER
        ldr r0, = 1<<(GPIOx_PIN*2)
        str r0, [r6]

        @ Load R2 and R3 with the "on" and "off" constants
        mov r2, 0               @ GPIO -> on
        mov r3, 1<<GPIOx_PIN    @ GPIO -> off
        ldr r6, = GPIOA_ODR     @ r6 <- address of ODR for port A

loop:
        str r2, [r6]            @ turn on LED
        ldr r1, = GPIO_DELAY
delay1:
        subs r1, 1
        bne delay1

        str r3, [r6]            @ turn off LED
        ldr r1, = GPIO_DELAY
delay2:
        subs r1, 1
        bne delay2

        b loop                  @ continue forever

_dummy:                         @ if any int gets triggered, just hang in a loop
_nmi_handler:
_hard_fault:
_memory_fault:
_bus_fault:
_usage_fault:
        add r0, 1               @ do some pointless arithmetic in loop
        add r1, 1
        b _dummy

        .end
