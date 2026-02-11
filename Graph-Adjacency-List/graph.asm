section .data
raw_data dq 42 , -7 , 19 , 88 , 3 , 56 , 14 , 91 , 27 , 60
DATA_COUNT equ 10
vertex_count dq 10

section .bss
; Memory pool for vertices (50 elements , each 16 bytes )
vertices resq 100

; Memory pool for edges (200 edges , each 16 bytes )
edges resq 400

edge_counter resq 1

section .text
global _start

_start :
; Step 1: Initialize graph with raw data
call init_graph

; Step 2: Add edges for testing
; Link 42 ( Index 0) to -7 ( Index 1)
mov rdi , 0
mov rsi , 1
call add_edge

; Link 42 ( Index 0) to 19 ( Index 2)
mov rdi , 0
mov rsi , 2
call add_edge

; Step 3: Insert a new vertex
mov rdi , 999
call insert_vertex ; Returns new index (10) in RAX

; Link new vertex ( Index 10) to 88 ( Index 3)
mov rdi , rax
mov rsi , 3
call add_edge

; Step 4: Remove an edge
; Remove link from 42 ( Index 0) to -7 ( Index 1)
mov rdi , 0
mov rsi , 1
call remove_edge

; Step 5: Verification
; Load data of Vertex 0 into registers for inspection
mov rdi , 0
call show_node

; Final Register State Expected :
; RAX = 42 ( Vertex data )
; RBX = 2 ( Index of neighbor 19)
; RCX = -1 (No more neighbors )

; Exit program
mov rax , 60 ; sys_exit
xor rdi , rdi ; return 0
syscall

; --- FUNCTIONS ---

; Initialize vertices from raw_data array
init_graph :
xor rcx , rcx ; loop counter i = 0
mov rsi , raw_data
mov rdi , vertices

.loop :
cmp rcx , DATA_COUNT
jge .done

mov rax , [ rsi + rcx *8] ; load value from raw_data

mov rbx , rcx
shl rbx , 4 ; offset = i * 16 bytes

mov [ rdi + rbx] , rax ; set vertex data
mov qword [rdi + rbx + 8] , 0 ; initialize head pointer to NULL

inc rcx
jmp .loop

.done :
mov qword [ edge_counter ] , 0
ret

; Create a directed edge between two vertices
; Input : RDI = source index , RSI = target index
add_edge :
mov rax , [ edge_counter ]
mov r8 , rax
shl r8 , 4 ; each edge is 16 bytes
lea r9 , [ edges + r8] ; r9 = address of new edge slot

mov [r9] , rsi ; store target index in edge

; Find source vertex address
mov r10 , rdi
shl r10 , 4
lea r11 , [ vertices + r10 ]

; Add to front of linked list ( Head insertion )
mov r12 , [ r11 + 8] ; r12 = current head
mov [r9 + 8] , r12 ; new_edge - > next = current head
mov [ r11 + 8] , r9 ; vertex - > head = new_edge

inc qword [ edge_counter ]
ret

; Add a new vertex to the vertex pool
; Input : RDI = data value , Output : RAX = new vertex index
insert_vertex :
mov rax , [ vertex_count ]

mov rbx , rax
shl rbx , 4 ; calculate memory offset
mov [ vertices + rbx ] , rdi ; store data
mov qword [ vertices + rbx + 8] , 0 ; no adjacent edges initially

inc qword [ vertex_count ]
ret

; Remove a specific edge from a vertex ’s adjacency list
; Input : RDI = source index , RSI = target index to remove
remove_edge :
mov r8 , rdi
shl r8 , 4
lea r9 , [ vertices + r8] ; r9 = address of source vertex

mov r10 , [r9 + 8] ; r10 = address of first edge
cmp r10 , 0
je .done ; list is empty

; Check if the first edge is the target
mov rcx , [ r10]
cmp rcx , rsi
jne .search_loop

; Remove head node
mov r11 , [ r10 + 8]
mov [r9 + 8] , r11
ret

.search_loop :
mov r11 , [ r10 + 8] ; r11 = next edge
cmp r11 , 0
je .done ; end of list

mov rcx , [ r11]
cmp rcx , rsi
je .found_middle

mov r10 , r11 ; advance pointers
jmp .search_loop

.found_middle :
; Bypass the target node in the linked list
mov rdx , [ r11 + 8]
mov [ r10 + 8] , rdx
ret

.done :
ret

; Load vertex data and its first two neighbors into registers
; Input : RDI = vertex index
; Output : RAX = data , RBX = 1st neighbor index , RCX = 2nd neighbor index
show_node :
mov rbx , -1 ; default if no neighbor
mov rcx , -1 ; default if no neighbor

mov r8 , rdi
shl r8 , 4
lea r9 , [ vertices + r8] ; r9 = vertex address

mov rax , [r9] ; RAX = vertex data

; Fetch first neighbor
mov r10 , [r9 + 8]
cmp r10 , 0
je .done
mov rbx , [ r10]

; Fetch second neighbor
mov r11 , [ r10 + 8]
cmp r11 , 0
je .done
mov rcx , [ r11]

.done :
ret
