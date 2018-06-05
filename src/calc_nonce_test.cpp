#include <iostream>
#include <string>
#include <cstring>
#include <cstdlib>

#include "calc_nonce.hpp"

//time
#include <time.h>
#include <sys/time.h>

using std::cout;
using std::endl;
using std::string;

//time
static void print_elapsed_time(struct timeval *s, struct timeval *e)
{
    long sec, usec;

    sec  = e->tv_sec - s->tv_sec;
    usec = e->tv_usec - s->tv_usec;
    if (usec < 0) {
	sec--; usec += 1000000;
    }
    cout << "elapsed time = " << sec << "." << usec << "sec." << endl;
}


int main(void){

    struct timeval s_time, e_time;      //time
    gettimeofday(&s_time, NULL);        /* get start-time */

    string *p_zero_num, *p_block[10], *p_nonce[10];

    p_zero_num = new string(6, '0');
    cout << "zero_num:" << *p_zero_num << endl;

    // calculate nonce
    for (int i = 0; i < 1; i++) {
        p_block[i] = new string(157, 'a');
        p_nonce[i] = calc_nonce(p_zero_num, p_block[i]);

        cout << "block:" << *p_block[i] << endl;
        cout << "nonce:" << *p_nonce[i] << endl;
    }

    // free dynamic memory
    delete p_zero_num;
    for(int i = 0; i < 1; i++){
        delete p_block[i];
        delete p_nonce[i];
    }

    //time
    gettimeofday(&e_time, NULL);        /* get end-time */
    print_elapsed_time(&s_time, &e_time);


    return 0;
}
