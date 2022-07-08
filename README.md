# Multimode CDC Modular Low Power Data Synchronizer

1. Applied to cross-clock domain transmission, covering most asynchronous data transmission situations.
2.Supports two clock sampling modes: fast sampling and slow sampling, and slow sampling and fast sampling. Supports three data sampling modes of bit width: single bit, multi-bit, single + multi-bit
3. It is composed of a level synchronization unit, an edge detection unit, a pulse synchronization unit, a DMUX unit and an asynchronous FIFO unit encoded by a Gray code pointer.
4. According to the actual data type and asynchronous clock conditions, different working modes can be flexibly selected, and the single-bit synchronization unit can be flexibly selected.
5. Turn off the unit modules that do not need to work through power gating, and reduce the frequency of flipping through Gray code encoding in asynchronous data stream transmission to reduce power consumption.
6. Each module is equipped with a clock gating unit to turn off the clock signal of the circuit modules that do not need to work to reduce power consumption.
About FIFO:


Very lean and fully functional asynchronous fifo
The FIFO consists of a MEM, a read control terminal, a write control terminal, a two-level synchronization unit and a binary Gray code conversion unit. 
Gray code pointer transfer is used to improve fault tolerance, and two-level synchronization is used to improve metastability. 
The empty and full state is judged by the additional bit of the read and write pointer.
