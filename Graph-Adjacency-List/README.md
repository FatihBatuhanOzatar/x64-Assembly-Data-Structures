
; PROJECT: x86-64 Assembly Graph (Adjacency List)
; AUTHOR: Fatih Batuhan Ozatar
; STATUS: Experimental / Research & Development
;
; DESCRIPTION:
; A directed graph implementation using manual memory management in x86-64 Assembly.
; Focuses on low-level pointer arithmetic and register-level data flow.
;
; TECHNICAL SPECS:
; - Memory Strategy: Pre-allocated vertex/edge pools in the .bss section.
; - Data Structure: Adjacency List using head-insertion logic.
; - Core Logic: Manual offset calculation for 16-byte node structures.
