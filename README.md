# UART-verilog-project
Implemented a complete UART transmitter–receiver system in Verilog HDL with baud rate generation, loopback integration, and simulation-based verification.
##  Project Overview
This project implements a UART communication system using Verilog HDL.  
It consists of a transmitter, a receiver, and a simple baud rate generator.  
A loopback setup is used to check correct data transfer between the modules.

##  Key Highlights
- UART transmitter and receiver written in Verilog
- Baud clock generated internally
- Start bit and stop bit based serial communication
- Loopback used for basic self-testing
- Testbench written to verify functionality

##  Verification
The design is verified through simulation. The transmitted serial data is  
fed back to the receiver, and the received output is observed to match the input.

