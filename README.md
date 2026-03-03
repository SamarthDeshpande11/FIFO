🔹 Project Overview

This project implements a parameterized synchronous FIFO (First-In First-Out) buffer in Verilog with integrated status flags and self-checking verification environment.
The design supports configurable data width and depth, includes overflow/underflow detection, and provides almost-full and almost-empty indicators for flow control applications.

🔹 Features

Parameterized WIDTH and DEPTH
Circular pointer-based memory architecture
Count-based full/empty detection
Almost full / almost empty flags
Overflow and underflow detection
Non-blocking sequential design
Self-checking testbench
Waveform-based verification

🔹 Design Architecture
1️⃣ Core Components

Write Pointer (wr_ptr)
Read Pointer (rd_ptr)
Occupancy Counter (count)
Dual-port memory array (mem)
Flow-control logic

2️⃣ Status Logic
Signal	Condition
empty	count == 0
full	count == DEPTH-1
almost_empty	count == 1
almost_full	count == DEPTH-2

Note: One slot is intentionally unused to avoid full/empty ambiguity.

3️⃣ Write Operation

Write allowed only if !full
Data written at mem[wr_ptr]
Pointer wraps at DEPTH-1
count increments when write occurs without read

4️⃣ Read Operation

Read allowed only if !empty
Data read from mem[rd_ptr]
Pointer wraps at DEPTH-1
count decrements when read occurs without write

5️⃣ Simultaneous Read & Write

When both occur in same cycle:
count remains unchanged
Pointers move independently

🔹 Key Design Concepts
✔ Non-blocking assignments (<=)
Used inside sequential always @(posedge clk) block to prevent race conditions.
✔ Circular Addressing
Pointers wrap around using:
wr_ptr <= (wr_ptr == DEPTH-1) ? 0 : wr_ptr + 1;
✔ Count-Based Status
Simplifies full/empty detection compared to pointer comparison logic.

🔹 Verification Strategy

The FIFO was verified using a self-checking testbench that includes:

Directed write and read tests

Full condition verification

Empty condition verification

Overflow detection test

Underflow detection test

Scoreboard-style data comparison

Waveform inspection using GTKWave

🔹 Simulation Setup

Toolchain:

Icarus Verilog

GTKWave

Run commands:

iverilog fifo.v fifo_tb.v
vvp a.out

Expected console output:

FIFO Test Completed
🔹 Example Waveform

(Insert screenshot here)

Waveform shows:

Correct pointer increment

Accurate full/empty assertion

Valid overflow/underflow detection

🔹 Applications

UART buffering

DMA buffering

Inter-module communication

Pipeline decoupling

Flow-control systems

🔹 Future Improvements

Asynchronous FIFO (dual clock)

Gray-code pointer implementation

SystemVerilog assertions

Randomized stress testing
