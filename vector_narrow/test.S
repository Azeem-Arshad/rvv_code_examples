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
# Enabling the vector operations byx setting mstatus bit
    li t1, 1024
    csrrs x0, mstatus, t1

    la t1, data_one                     # Loading the data_one address
    la t2, data_two                     # Loading the data_two address
    li a2, 0x2

    li a0, 8                           # AVL

    vsetvli a1, a0, e16, mf2, ta, ma     # SEW = 4 bits, LMUL = 1/2, AVL = 4
                                                                                   
    # Loading data to vectors

    vle32.v v2, (t2)
    vadd.vi v1, v0, 1
    
    
    vnsrl.wi v3, v2, 1                 # Vector-Vector additon with narrowing
    vnsrl.wv v4, v2, v1

    j write_tohost

.align 2    
write_tohost:
    li gp, 1
    sw gp, tohost, t5
    j write_tohost
    
.data
data_one:              
.word 0xfebaceef
.word 0xdeabdeef
.word 0xcafebeef
.word 0xffffffff
.word 0x00001000
.word 0x01000010
.word 0x10000000
.word 0x90078601

data_two:   
.word 0xabcdef12
.word 0x345345ab
.word 0xabcdabcd
.word 0x67899876
.word 0x11221122
.word 0xceabfeed
.word 0xbeefdeef
.word 0xc0defead

data_mask:
.word 0b10010001


RVTEST_DATA_BEGIN
