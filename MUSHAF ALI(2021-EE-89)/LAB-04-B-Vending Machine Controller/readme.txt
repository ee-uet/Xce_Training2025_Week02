 ############################################### Vending Machine (FSM with Coin Synchronization) ####################################

This project implements a Moore FSM-based vending machine in Verilog, with coin synchronization to avoid metastability.

Modules
##synchronization_for_coins

Synchronizes external coin inputs (coin_5, coin_10, coin_25) with the system clock.

Uses back-to-back flip-flops to stabilize inputs.

Generates one-cycle pulses (coin_5_pulse, coin_10_pulse, coin_25_pulse).

##vending_machine

Implements FSM with states for different amounts (S0, S5, S10, ... S30), DISPENSE_ITEM, and RETURN_MONEY.

##Inputs: Coin pulses, clock, reset, and return_req.

##Outputs: Item dispense signal, return coins (return_5, return_10, return_25), and balance tracking (amount).

##Features

Accepts coins of 5, 10, and 25.

Dispenses item when amount >= 30.

Supports return request to give change back.

Change return logic is greedy: tries largest coins first (25 → 10 → 5).

Tracks internal coin quantities and enables Exact Change Only mode when coins are insufficient.


################################################### AI USAGE ################################
NOTE#01 : Design code is written by me and fully understand the working 
NOTE#02 :Testbench is taken from chatgpt to completely test the module basic tb is easy but to test design in detail i take help from chatgpt but next week     is totally for verification so inshallah i will learn to write detailed layered tb as by myself inshallah