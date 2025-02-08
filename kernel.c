
/*******************************************************************************************
 * 
 *  Author:     Riley Grimaud
 *  File Name:  kernel.c
 *  Date:       09/30/2024
 *  Purpose:    given a startrow, endrow, startcolumn, and end column within the machine's screen limits,
 *              this program will print a message of your choosing and make a box around it using
 *              ARM 64 bit Assembly language
 * 
 * 
 *************************************************************************************************/

#include "libos.h"

//void putc_to(unsigned int row, unsigned int col, const char c);
int clear_scr(unsigned int start_row, unsigned int start_col, unsigned int width, unsigned int height);
int term_txtheight();
int term_txtwidth();
extern int box(unsigned int srow, unsigned int scol, unsigned int erow, unsigned int ecol);
//extern int print_to(unsigned int row, unsigned int col, char *string);

int main(){
    int error_code;

    //call clear_scr with the start row, start column, end row, and end column

    unsigned int sr = 21;
    unsigned int sc = 49;
    unsigned int er = 27;
    unsigned int ec = 79;
    

    error_code = clear_scr(sr, sc, er, ec);

    if (error_code == 1){
        print_to(24, 59, "Error clearing the screen. Check screen input dimensions");
    }


    error_code = box(sr, sc, er, ec);

    if (error_code == 1){
        print_to(24, 59, "Error forming box");
    }

    else{
        print_to(24, 59, "Hello World");
    }
}

int clear_scr(unsigned int start_row, unsigned int start_col, unsigned int er, unsigned int ec){
    
    unsigned int height = term_txtheight();
    unsigned int width = term_txtwidth();

    if ((start_row >= er) || (start_col >= ec)){
        return 1;
    }

    else if ((er >= height) || (ec >= width)){
        return 1;
    }
    
    else {

        for (unsigned int i = start_row; i <= er; i++){
            for (unsigned int j = start_col; j <= ec; j++){
                putc_to(i, j, ' ');
            }
        }
    }

    return 0;
}