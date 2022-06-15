# Asyn_fifo
Very lean and fully functional asynchronous fifo
The FIFO consists of a MEM, a read control terminal, a write control terminal, a two-level synchronization unit and a binary Gray code conversion unit. 
Gray code pointer transfer is used to improve fault tolerance, and two-level synchronization is used to improve metastability. 
The empty and full state is judged by the additional bit of the read and write pointer.
