 ################################################## Traffic Light Controller with Timer #########################################

This project implements a traffic light control system using Verilog. It consists of two modules:

##clk_to_timer

Generates periodic time pulses (time_5s, time_10s, time_30s).

Supports synchronous resets from system reset, emergency, or pedestrian request.

Internally uses counters to trigger pulses at respective intervals.

##trafic_light_controler

Finite State Machine (FSM) controls traffic lights for North-South (NS) and East-West (EW) directions, plus pedestrian crossing.

States: Startup Flash, NS Green/EW Red, NS Yellow/EW Red, NS Red/EW Green, NS Red/EW Yellow, Pedestrian Request, and All-Red Emergency.

##Inputs: Timer pulses, emergency signal, pedestrian request.

##Outputs:

ns_lights → NS traffic light (Green, Yellow, Red).

es_lights → EW traffic light (Green, Yellow, Red).

ps_walk → Pedestrian Walk/Don’t Walk.

Reset flags (emergency_reset, padestrian_reset) to sync with timer module.

##Key Features

Pedestrian request handling with priority after cycle completion.

Emergency mode forces all-red state until emergency clears.

Dynamic synchronization between FSM and timer using reset flags.


################################################### AI USAGE ################################
NOTE#01 : Design code is written by me and fully understand the working 
NOTE#02 :Testbench is taken from chatgpt to completely test the module basic tb is easy but to test design in detail i take help from chatgpt but next week     is totally for verification so inshallah i will learn to write detailed layered tb as by myself inshallah