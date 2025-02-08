.global     box
.extern     putc_to
.extern     term_txtwidth
.extern     term_txtheight
box:
 
    // standard entry: save link and stack frame registers
    //    load the stack frame with the pointer to current frame
    stp     x29, x30, [sp, -16]!
    mov x29, sp

    // Save the arguments.  Called functions may overwrite x0-x3
    sub     sp, sp, 32
    stp     x0, x1, [sp]
    stp     x2, x3, [sp, 16]

    // sr in w0, sc in w1, er int w2, ec in w3
    
    // Make sure the argument are valid

    bl      _box_check_box_
    cmp     w0, 0
    bne     _box_error_

 
    // first, draw the corners:
    // +        +
    // +        +
    ldp     x0, x1, [sp]
    ldp     x2, x3, [sp, 16]
    bl      _box_draw_corners_

    // Now, draw the top and bottom:
    // +------+
    // +------+
    ldp     x0, x1, [sp]
    ldp     x2, x3, [sp, 16]
    bl _box_draw_top_bottom_

    // draw left and right sides
    ldp     x0, x1, [sp]
    ldp     x2, x3, [sp, 16]
    bl _box_draw_left_right_

    // You figure out what goes here

    mov     w0, 0
    b       _box_exit_


_box_error_:
    mov     w0, 1

_box_exit_:
    add     sp, sp, 32   // pop save arg regs

    ldp     x29, x30, [sp], 16
    ret

_box_check_box_:

    stp x29, x30, [sp, -16]!
    mov x29, sp

 //   sub     sp, sp, 32
  //  stp     x0, x1, [sp]
  //  stp     x2, x3, [sp, 16]

    mov w16, w0     //sr
    mov w17, w1     //sc
    mov w18, w2     //er
    mov w19, w3     //ec

    bl term_txtheight           //I'm not sure this is right - how do I know the returned value of term_txtheight will be in w0?
    mov w4, w0                  //should I use ldr or should I use mov?

    bl term_txtwidth
    mov w5, w0

    //ldp x0, x1, [sp]
    //ldp x2, x3, [sp, 16]

    cmp w18, w4   //er SHOULD BE < textheight
    bge _branch_error_

    cmp w18, w16   //er SHOULD BE > sr
    ble _branch_error_

    cmp w19, w17   //ec SHOULLD BE > sc
    ble _branch_error_

    cmp w19, w5   //ec SHOULD BE < textwidth
    bge _branch_error_

    mov w0, 0

    //add     sp, sp, 32   // pop save arg regs

    ldp x29, x30, [sp], 16
    ret

_branch_error_:
    mov w0, 1

    //add     sp, sp, 32   // pop save arg regs

    ldp x29, x30, [sp], 16
    ret

_box_draw_corners_:

    //void _box_draw_corners_(
    //    unsigned int start_row,
    //    unsigned int start_column,
    //    unsigned int end_row,
    //    unsigned int end_column);
    //Uses the putc_to() function to draw a '+' on the screen at (start_row, start_column), at (start_row, end_column), 
    //at (end_row, start_column), and (end_row, end_column). 

    stp x29, x30, [sp, -16]!
    mov x29, sp

    sub     sp, sp, 32          //make room for four values on stack
    stp     x0, x1, [sp]
    stp     x2, x3, [sp, 16]    //store sr, sc, er, ec for later on stack


    //x0 sr, x1 sc, x2 er, x3 ec
    mov x2, '+'                 //preparing args for putc_to(sr, sc, '+')
    bl putc_to                  //remember sr and sc are already in x0, x1


    ldr x0, [sp]                //preparing args for putc_to(sr, ec, '+')
    ldr x1, [sp, 24]
    mov x2, '+'
    bl putc_to


    ldr x0, [sp, 16]            //preparing args for putc_to(er, sc, '+')
    ldr x1, [sp, 8]
    mov x2, '+'
    bl putc_to

    ldr x0, [sp, 16]              //preparing args for putc_to(er, ec, '+')
    ldr x1, [sp, 24]
    mov x2, '+'
    bl putc_to

    add     sp, sp, 32           // pop save arg regs

    ldp     x29, x30, [sp], 16
    ret

//    void _box_draw_top_bottom_(
//    unsigned int start_row,
//    unsigned int start_column,
//    unsigned int end_row,
//    unsigned int end_column);

//Uses a loop to draw the top and bottom lines of the box.  The top line is drawn from (start_row, start_column + 1) 
//to (start_row, end_column - 1).  Likewise, the bottom line is drawn from (end_row, start_column+1) to 
//(end_row, end_column - 1).  putc_to() is used to draw the '-' character that make up the top and bottom lines.

_box_draw_top_bottom_:
    
    stp x29, x30, [sp, -16]!
    mov x29, sp

    //sub     sp, sp, 32          //make room for four values on stack
    //stp     x16, x17, [sp]
    //stp     x18, x19, [sp, 16]    //store sr, sc, er, ec for later on stack

    mov x16, x0     //sr
    mov x17, x1     //sc
    mov x18, x2     //er
    mov x19, x3     //ec

    mov x20, x17                 //mov sc into x4 and use it to keep track of current place
    add x20, x20, 1               //don't need to overwrite the top left corner with an -

    _do_while_top_line_:
        
        mov x0, x16           //preparing args for putc_to(sr, x20, '-')
        mov x1, x20
        mov x2, '-'
        bl putc_to

        add x20, x20, 1
        
        cmp x20, x19              //check if current location is at ec yet
        bne _do_while_top_line_
    


    mov x20, x17                //reload x20 with sc
    add x20, x20, 1             //skip over the bottom left corner

    _do_while_bottom_line_:
        
        mov x0, x18           //preparing args for putc_to(er, x20, '-')
        mov x1, x20
        mov x2, '-'
        bl putc_to

        add x20, x20, 1
        
        cmp x20, x3              //check if current location is at ec yet
        bne _do_while_bottom_line_


    //add     sp, sp, 32           // pop save arg regs

    ldp     x29, x30, [sp], 16
    ret


_box_draw_left_right_:

    stp x29, x30, [sp, -16]!
    mov x29, sp

    mov x16, x0     //sr
    mov x17, x1     //sc
    mov x18, x2     //er
    mov x19, x3     //ec


    mov x20, x16                //load x20 with sr
    add x20, x20, 1             //skip over the top left corner

    _do_while_left_side_:
        
        mov x0, x20           //preparing args for putc_to(x20, sc, '|')
        mov x1, x17
        mov x2, '|'
        bl putc_to

        add x20, x20, 1
        
        cmp x20, x18              //check if current location is at er yet
        bne _do_while_left_side_



    mov x20, x16                //load x20 with sr
    add x20, x20, 1             //skip over the top right corner

    _do_while_right_side_:
        
        mov x0, x20           //preparing args for putc_to(x20, ec, '|')
        mov x1, x19
        mov x2, '|'
        bl putc_to

        add x20, x20, 1
        
        cmp x20, x18              //check if current location is at er yet
        bne _do_while_right_side_


    ldp     x29, x30, [sp], 16
    ret