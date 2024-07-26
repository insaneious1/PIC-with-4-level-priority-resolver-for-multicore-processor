# PIC-with-4-level-priority-resolver-for-multicore-processor


# Overview
This project implements a programmable interrupt controller designed for a quad-core processor. It features dynamic priority assignment for interrupt requests and supports parallel servicing of interrupts for each core. The controller ensures high-priority requests are served first while handling up to four interrupt requests per core simultaneously.

# Features
Dynamic Priority Assignment: Interrupt priorities can be assigned and adjusted dynamically, providing flexible interrupt management.
Parallel Request Servicing: Capable of handling multiple interrupt requests concurrently.Support for 32 Interrupt Lines.
Priority Resolver: Resolves interrupt requests based on their priority to ensure the highest priority interrupt is selected for servicing.
Interrupt Service Routine (ISR) Vector: Stores addresses of service routines for each interrupt type, allowing quick and efficient response to interrupts.
Components
Interrupt Request Lines (IRQ):
Four request lines for each core.
Total of 32 request lines.
Priority Registers:
Hold the priority level for each interrupt.
Can be updated dynamically to adjust priority levels.
Priority Encoder:
Encodes the interrupt requests based on their priority.
Ensures the highest priority interrupt is selected for servicing.
Interrupt Service Routine (ISR) Vector:
Holds the record of the request that is being served.
Control Logic:
Manages the assignment and servicing of interrupts.
Repository Structure
