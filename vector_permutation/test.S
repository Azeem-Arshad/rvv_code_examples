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


    la t0, data_mask                     # Loading the data_mask address
    la t1, data_one                     # Loading the data_one address
    la t2, data_two                     # Loading the data_two address

    li a0, 8                           # AVL

    vsetvli a1, a0, e32, m1, ta, ma     # SEW = 32 bits, LMUL = 1, AVL = 8

    # Loading data to vectors

    vle32.v v0, (t0)                    
    vle32.v v1, (t1)
    vle32.v v2, (t2)
    
    ## Integer Scalar Move
    vmv.x.s a2, v1                      # first element from v1 to a2
    vmv.s.x v3, a2                      # From a2 to first element of v3

    

    # Vector slide up
    li a3, 3
    vslideup.vx v4, v1, a3
    vslideup.vi v5, v1, 2

    # Vector Slidedown
    vslidedown.vx v6, v2, a3
    vslidedown.vi v7, v2, 4

    # vector Slide1Up
    vslide1up.vx v4, v1, a3
    vslide1up.vx v5, v2, a3

    # Vector Slide1Down
    vslide1down.vx v6, v2, a3

    # Vector Register Gather
    vrgather.vv v8, v4, v5

    # Vector Compress Instruction
    vcompress.vm v9,v1,v0


    # Whole register Move
    vmv1r.v v1, v2
    vmv4r.v v8, v4

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
.word 0xcafebeef
.word 0xdeadbeef
.word 0xabcdef12
.word 0x345345ab
.word 0xabcdabcd
.word 0x67899876
.word 0x11221122
.word 0xceabfeed

data_mask:
.word 0b10010001


RVTEST_DATA_BEGIN
