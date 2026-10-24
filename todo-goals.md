Goal is to get an idea of the pysical mem layout without editing the source code
Or maybe do edit source code?

what we need

PID
page table iformation

***********
Can we edit the pwalk syscall or add another syscall that maps the entireity of the address space to virtual addresses/processes?

The goal here would be to create structured output data that describes the physical memory and maps it to virtual memory/processes.

This structured data could be used in the visualizer to create an interactive "memory map" that allows the user to explore where
per process variables exist in physical memory, and where the virtual pages exist in physical memory.

Steps 
- Map the OS memory into an "OS block". Eventually add more specific subdivision here
- Walk every page table and map each physical page to a process
- For given process, map the symbols to the virtual page that they are contained within