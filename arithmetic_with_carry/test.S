#define RVTEST_DATA_BEGIN                                               \
        .pushsection .tohost,"aw",@progbits;                            \
        .align 6; .global tohost; tohost: .dword 0; .size tohost, 8;    \
        .align 6; .global fromhost; fromhost: .dword 0; .size fromhost, 8;\
        .popsection;                                                    \
        .align 4; .global begin_signature; begin_signature:
#define RVTEST_CODE_BEGIN                                               \
        .section .text.init;                                            \
        .align  6;                                                      \
        .global _start;                         \
_start:                                 \
        j main;                             \
trap_vector:                                                            \
    csrr t5, mcause ;                       \
    nop;                                \
    nop;                                \
    nop;                                \
    nop;                                \
    nop;                                \
    j write_tohost
RVTEST_CODE_BEGIN
main:
# Enabling the vector operations by setting mstatus bit
    li t1, 1024
    csrrs x0, mstatus, t1

    la t1, data_one                     # Loading the data_one address
    la t2, data_two                     # Loading the data_two address

    li a0, 8                           # AVL
    li a2, 0xffffffff
    vsetvli a1, a0, e32, m1, ta, ma     # SEW = 32 bits, LMUL = 1, AVL = 8

    # Loading data to vectors
    vle32.v v1, (t1)
    vle32.v v2, (t2)

    vmadc.vvm v4, v2, v1, v0                # carry calculations    
    vadc.vvm v3, v2, v1, v0                  # Vector-Vector additon with carry
    vmmv.m v0, v4                           # Move carry to v0 


    
    j write_tohost   

.align 2    
write_tohost:
    li gp, 1
    sw gp, tohost, t5
    j write_tohost
    
.data
data_one:              
.word 0x10101001
.word 0x23423423
.word 0x90909090
.word 0x0ff0f00f
.word 0x90001000
.word 0x01000010
.word 0x10000000

data_two:              
.word 0x50360541
.word 0xdeadbeef
.word 0xabcdef12
.word 0x01001101
.word 0xabcdabcd
.word 0x67899876
.word 0x11221122
.word 0xceabfeed

data_mask:
.word 0b10010001


RVTEST_DATA_BEGIN
