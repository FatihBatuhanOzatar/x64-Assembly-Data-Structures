section .data
xor_data dq 42 , -7 , 19 , 88 , 3 , 56 , 14 , 91 , 27 , 60
XOR_COUNT equ 10

section .bss
; Memory Pool (50 nodes * 16 bytes = 800 bytes )
xor_nodes resq 100

; Management Variables
xor_free_ptr resq 1 ; Address of next free memory slot
head_ptr resq 1 ; List Head
tail_ptr resq 1 ; List Tail

section .text
global _start

_start :
; STEP 1: INITIALIZATION
call init_xor_list

; STEP 2: INSERTION (The " Middle " Operation )
; Requirement : Insert 999 exactly after the 5th element ( Index 4).
mov rdi , 4 ; Target Index (4)
mov rsi , 999 ; Value to Insert
call xor_insert_after

; STEP 3: REMOVAL ( Logic Repair )
; Requirement : Remove the node containing the value -7.
mov rdi , -7 ; Value to Remove
call xor_remove_by_value

; STEP 4: OUTPUT ( Bidirectional Verification )
; Forward Pass (RAX ) and Backward Pass ( RBX )
call xor_output_results

; EXIT
mov rax , 60 ; sys_exit
xor rdi , rdi ; return 0
syscall

; =============================================================
; FUNCTION : init_xor_list
; Purpose : Initializes the list from xor_data using single - pass construction .
; =============================================================
init_xor_list :
mov qword [ head_ptr ] , 0
mov qword [ tail_ptr ] , 0

mov rax , xor_nodes
mov [ xor_free_ptr ] , rax

xor rcx , rcx ; Counter i = 0
mov rsi , xor_data ; Source array
.loop :
cmp rcx , XOR_COUNT
jge .done

; Allocate new node
mov rdi , [ xor_free_ptr ] ; rdi = Current node address

; Write data
mov rax , [ rsi + rcx *8]
mov [ rdi ] , rax

; Increment free pointer
add qword [ xor_free_ptr ] , 16

; Link with previous node
mov rbx , [ tail_ptr ] ; rbx = Old Tail ( Prev )
cmp rbx , 0
je .first_node

; Case : Append to existing list
; 1. New Node NPX = Prev XOR 0 -> Prev
mov [ rdi + 8] , rbx

; 2. Update Previous Node NPX
; Rule : Prev - >npx = Prev - >npx XOR Current
mov rdx , [ rbx + 8] ; rdx = Old NPX
xor rdx , rdi ; rdx = Old NPX XOR New Address
mov [ rbx + 8] , rdx ; Write back

; 3. Update Tail
mov [ tail_ptr ] , rdi
jmp .next_iter

.first_node :
; Case : First Node
mov qword [rdi + 8] , 0 ; npx = 0
mov [ head_ptr ] , rdi
mov [ tail_ptr ] , rdi

.next_iter :
inc rcx
jmp .loop

.done :
ret

; =============================================================
; FUNCTION : xor_insert_after
; Purpose : Inserts a new node after the specified index .
; Inputs : RDI = Target Index , RSI = Value to Insert
; =============================================================
xor_insert_after :
push rbx
push r12
push r13
push r14
push r15

; Step 1: Find Target Node (A)
mov r8 , [ head_ptr ] ; r8 = Node A ( Current )
mov r9 , 0 ; r9 = Node P ( Prev )
xor rcx , rcx ; Counter

.search_loop :
cmp rcx , rdi
je .found

cmp r8 , 0
je .done_err ; Error : Index out of bounds

; Traverse : Next = Current - > npx XOR Prev
mov rdx , [r8 + 8]
xor rdx , r9

mov r9 , r8 ; Prev = Current
mov r8 , rdx ; Current = Next
inc rcx
jmp .search_loop

.found :
; r8 = Node A ( Target ), r9 = Node P ( Prev )

; Find Node C ( Next ): C = A- > npx XOR P
mov r10 , [r8 + 8]
xor r10 , r9 ; r10 = Node C

; Step 2: Create New Node (B)
mov r11 , [ xor_free_ptr ]
add qword [ xor_free_ptr ] , 16
mov [ r11 ] , rsi ; B- > Data = Value

; Step 3: Calculate B- > npx = A XOR C
mov rax , r8
xor rax , r10
mov [ r11 + 8] , rax

; Step 4: Update A- >npx = P XOR B
mov rax , r9
xor rax , r11
mov [r8 + 8] , rax

; Step 5: Update C- >npx (if exists )
cmp r10 , 0
je .update_tail

; C- > npx = Old_NPX_C XOR A XOR B
mov rax , [ r10 + 8]
xor rax , r8 ; Remove A
xor rax , r11 ; Add B
mov [ r10 + 8] , rax
jmp .done

.update_tail :
mov [ tail_ptr ] , r11 ; B is the new Tail

.done :
pop r15
pop r14
pop r13
pop r12
pop rbx
ret

.done_err :
pop r15
pop r14
pop r13
pop r12
pop rbx
ret

; =============================================================
; FUNCTION : xor_remove_by_value
; Purpose : Finds a node by value and removes it.
; Input : RDI = Value to remove
; =============================================================
xor_remove_by_value :
push rbx
push r12
push r13
push r14
push r15

; Step 1: Find Node ( Target )
mov r8 , [ head_ptr ] ; r8 = Current ( Target candidate )
mov r9 , 0 ; r9 = Prev

.search_loop :
cmp r8 , 0
je .not_found

mov rax , [r8]
cmp rax , rdi
je .found

; Traverse
mov rdx , [r8 + 8]
xor rdx , r9
mov r9 , r8
mov r8 , rdx
jmp .search_loop

.found :
; r8 = Target (T), r9 = Prev (P)

; Find Next (N) = T- > npx XOR P
mov r10 , [r8 + 8]
xor r10 , r9

; Step 2: Update Prev (P)
cmp r9 , 0
je .update_head

; P- > npx = P- >npx XOR T XOR N
mov rax , [r9 + 8]
xor rax , r8
xor rax , r10
mov [r9 + 8] , rax
jmp .step3

.update_head :
mov [ head_ptr ] , r10

.step3 :
; Step 3: Update Next (N)
cmp r10 , 0
je .update_tail

; N- > npx = N- >npx XOR T XOR P
mov rax , [ r10 + 8]
xor rax , r8
xor rax , r9
mov [ r10 + 8] , rax
jmp .done

.update_tail :
mov [ tail_ptr ] , r9

.done :
.not_found :
pop r15
pop r14
pop r13
pop r12
pop rbx
ret

; =============================================================
; FUNCTION : xor_output_results
; Purpose : Traverses list forward ( RAX ) and backward ( RBX ).
; =============================================================
xor_output_results :
; Forward Pass ( Head -> Tail )
mov r8 , [ head_ptr ]
mov r9 , 0

.forward_loop :
cmp r8 , 0
je .start_backward

mov rax , [r8] ; Load Data into RAX

; Next = npx XOR Prev
mov rdx , [r8 + 8]
xor rdx , r9

mov r9 , r8
mov r8 , rdx
jmp .forward_loop

.start_backward :
; Backward Pass ( Tail -> Head )
mov r8 , [ tail_ptr ]
mov r9 , 0

.backward_loop :
cmp r8 , 0
je .done

mov rbx , [r8] ; Load Data into RBX

; Prev = npx XOR Next
mov rdx , [r8 + 8]
xor rdx , r9

mov r9 , r8
mov r8 , rdx
jmp .backward_loop

.done :
ret
