# Graph Adjacency List

A directed graph implementation using manual memory management.

### Key Features
* **Memory Pool:** Pre-allocated vertex and edge slots in the `.bss` section to avoid dynamic allocation overhead.
* **Logic:** Adjacency list approach using head-insertion for edges.
* **Core Focus:** Pointer arithmetic and manual memory offset calculations using 64-bit registers.

### Purpose
To demonstrate the fundamental handling of graphs without high-level abstractions, focusing on raw memory layout.
