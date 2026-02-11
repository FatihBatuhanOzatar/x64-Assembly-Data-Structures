# XOR Linked List

A memory-optimized doubly linked list implementation using bitwise operations.

### Concept
Instead of storing two separate pointers (prev/next), this implementation stores a single `npx` (next-prev XOR) value in each node.

### The Formula
The address of the next or previous node is calculated using:
$$npx = \text{address}(\text{prev}) \oplus \text{address}(\text{next})$$



### Core Focus
* Bitwise XOR operations for pointer encoding/decoding.
* Bidirectional traversal within a low-level environment.
* Memory efficiency (reducing pointer overhead by 50%).
