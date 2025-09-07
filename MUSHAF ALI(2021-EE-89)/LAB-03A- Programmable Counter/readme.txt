######################################################## Programmable Up/Down Counter ####################################################

This Verilog module implements an 8-bit programmable up/down counter with upper and lower limit handling, dynamic load capability, and status outputs.

##Features

Clock & Reset: Counter updates on rising clock edge, resets to 0 on reset.

Enable Control: Counts only when enable = 1.

Up/Down Selection: updown = 1 → increment, updown = 0 → decrement.

Load Function: Loads external load_data into the counter when load = 1.

##Upper/Lower Limits:

Stops incrementing when reaching upper_limit.

Stops decrementing when reaching lower_limit.

Handles dynamic changes to limits safely.

##Outputs:

terminal_count: High when counter reaches upper/lower limit.

zero_count: High when counter value is 0.

count: Current 8-bit counter value.

##Use Case

This counter is useful in digital systems requiring bounded counting, such as timers, PWM generators, and event counters with programmable limits.


################################################### AI USAGE ################################
NOTE#01 : Design code is written by me and fully understand the working 
NOTE#02 :Testbench is taken from chatgpt to completely test the module basic tb is easy but to test design in detail i take help from chatgpt but next week     is totally for verification so inshallah i will learn to write detailed layered tb as by myself inshallah