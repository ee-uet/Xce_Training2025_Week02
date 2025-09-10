 ########################################################### Multi-Mode Timer #########################################

This module implements a programmable timer with four operating modes. It uses a divided clock input and can be configured to support hold, one-shot, periodic, and PWM modes.

##Features

##Mode selection (mode_sel)

00: Hold Mode – Holds the loaded value, no counting.

01: One-Shot Mode – Counts down from Load_Value once, then raises an interrupt.

10: Periodic Mode – Repeatedly counts down from Load_Value to zero, reloads automatically, and raises an interrupt.

11: PWM Mode – Generates a PWM signal using Load_Value and duty_cycle.

##Inputs

divided_clk: Clock input (already divided to required frequency).

rst: Active-high reset.

mode_sel: Selects timer mode.

start: Enables counting.

duty_cycle: Used in PWM mode.

Load_Value: Initial count value.

##Outputs

pwm_out: PWM output in PWM mode.

one_shot_mode_interupt: Raised when one-shot timer finishes.

periodic_mode_interupt: Raised at the end of each period in periodic mode.

pwm_mode_interupt: Raised at the end of each PWM cycle.

count_out: Current counter value.


################################################### AI USAGE ################################
NOTE#01 : Design code is written by me and fully understand the working 
NOTE#02 :Testbench is taken from chatgpt to completely test the module basic tb is easy but to test design in detail i take help from chatgpt but next week     is totally for verification so inshallah i will learn to write detailed layered tb as by myself inshallah