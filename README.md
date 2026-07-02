# UART Transmitter and Receiver in Verilog

## Overview

This project implements a **Universal Asynchronous Receiver Transmitter (UART)** in Verilog HDL. The design consists of independent transmitter and receiver modules driven by a baud rate generator and integrated through a top-level module.

The transmitter converts parallel 8-bit data into a serial stream, while the receiver reconstructs the original byte using **16× oversampling** for reliable asynchronous communication.

The project is written in synthesizable Verilog and can be simulated using tools such as **Icarus Verilog**, **GTKWave**, **Vivado**, or **ModelSim**.

---

## Features

- 8-bit UART Transmission
- 8-bit UART Reception
- Independent Transmitter and Receiver
- FSM-based Design
- Baud Rate Generator
- 16× Receiver Oversampling
- Start Bit Detection
- Stop Bit Verification
- Busy Flag during Transmission
- Ready Flag after Successful Reception
- Modular and Synthesizable RTL

---

## UART Frame Format

The implemented UART frame follows the standard format:

| Start | Data Bits | Stop |
|--------|-----------|------|
| 1 bit | 8 bits (LSB First) | 1 bit |

Configuration:

- Parity : None
- Data Bits : 8
- Stop Bits : 1
- Transmission Order : Least Significant Bit (LSB) First

---

# Project Structure

```
UART/
│
├── baud_generator.v
├── uart_transmitter.v
├── uart_receiver.v
├── uart_top.v
├── testbench.v
└── README.md
```

---

# Module Description

## 1. Baud Generator

The baud generator creates enable pulses for both the transmitter and receiver.

### Transmitter Enable

- Generates one enable pulse every baud period.
- Controls when each serial bit is transmitted.

### Receiver Enable

- Generates enable pulses at **16× the baud rate**.
- Enables oversampling for accurate reception.

---

## 2. UART Transmitter

The transmitter accepts an 8-bit parallel input and serializes it into a UART frame.

### Functional Flow

1. Waits in Idle state.
2. Loads input data when `wr_en` is asserted.
3. Sends the Start Bit.
4. Transmits all eight data bits.
5. Sends the Stop Bit.
6. Returns to Idle.

### Outputs

- Serial TX line
- Busy status

---

## 3. UART Receiver

The receiver continuously monitors the RX line.

When a falling edge is detected:

1. Confirms a valid Start Bit.
2. Samples each incoming bit at the center of the bit period.
3. Reconstructs the received byte.
4. Verifies the Stop Bit.
5. Raises the Ready flag after successful reception.

The receiver uses **16× oversampling**, making reception more robust against timing mismatch.

---

## 4. Top Module

The top module integrates:

- Baud Generator
- UART Transmitter
- UART Receiver

It provides a single interface for transmission and reception.

---

# Finite State Machines

## UART Transmitter FSM

```
Idle
  │
  ▼
Start Bit
  │
  ▼
Data Bits
  │
  ▼
Stop Bit
  │
  └────────► Idle
```

---

## UART Receiver FSM

```
Detect Start
      │
      ▼
Receive Data
      │
      ▼
Check Stop Bit
      │
      └────────► Ready
```

---

# Receiver Oversampling

Unlike the transmitter, the receiver samples the incoming serial signal **16 times per bit**.

Advantages include:

- Improved noise immunity
- Better tolerance to clock mismatch
- Reliable sampling at the center of each bit
- Reduced probability of framing errors

The receiver validates the start bit before capturing data and verifies the stop bit before asserting the Ready signal.

---

# Control Signals

| Signal | Description |
|---------|-------------|
| `wr_en` | Starts a new transmission |
| `busy` | Indicates transmitter is active |
| `rdy` | Indicates valid received data |
| `rdy_clr` | Clears the Ready flag |
| `tx` | Serial transmit output |
| `rx` | Serial receive input |

---

# Design Highlights

- Modular RTL implementation
- Separate transmitter and receiver logic
- FSM-based control
- Parameterized state machine architecture
- Clean synchronous design
- Synthesizable Verilog
- Suitable for FPGA implementation

---

# Working Principle

### Transmission

- Parallel data is loaded.
- UART frame is generated.
- Bits are transmitted sequentially.
- Transmission completes after the stop bit.

### Reception

- Receiver detects the start bit.
- Performs 16× oversampling.
- Samples each data bit at the bit center.
- Verifies the stop bit.
- Stores the received byte.
- Raises the Ready signal.

---

# Simulation Parameters

The current implementation is configured for simulation using:

| Parameter | Value |
|-----------|-------|
| System Clock | 50 MHz |
| UART Baud Rate | 1 Mbps |
| Receiver Oversampling | 16× |

These values can be modified by changing the baud generator counters.

---

# Applications

- FPGA-to-FPGA Communication
- FPGA-to-Microcontroller Interface
- Debug UART
- Embedded Systems
- Sensor Communication
- Serial Data Transfer
- Educational Digital Design Projects

---

# Future Improvements

- Configurable Baud Rate
- Configurable Data Width
- Even/Odd Parity Support
- Multiple Stop Bits
- FIFO Buffers
- Error Detection (Parity, Framing, Overrun)
- Interrupt Support
- AXI/APB Interface
- Parameterized UART Core

---

# Tools Used

- Verilog HDL
- Icarus Verilog
- GTKWave
- Xilinx Vivado (Compatible)
- ModelSim (Compatible)

---

# Learning Outcomes

This project demonstrates:

- Finite State Machine (FSM) Design
- UART Communication Protocol
- Serial Data Transmission
- Asynchronous Communication
- Clock Enable Generation
- Receiver Oversampling
- Synchronization Techniques
- RTL Design using Verilog
- FPGA-Oriented Digital Design

---

# Author

**Swaranjith Reddy Peesu**

Electronics and Communication Engineering  
National Institute of Technology Rourkela
