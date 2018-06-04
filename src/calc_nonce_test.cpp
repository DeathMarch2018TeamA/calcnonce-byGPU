#include <iostream>
#include <string>
#include <cstring>
#include <cstdlib>

#include "calc_nonce.hpp"

using std::cout;
using std::endl;
using std::string;


int main(void){

    string *p_zero_num, *p_block[10], *p_nonce[10];
    srand(1);

    p_zero_num = new string(3, '0');
    cout << "zero_num:" << *p_zero_num << endl;

    // calculate nonce
    for (int i = 0; i < 1; i++) {
        p_block[i] = new string(5, 'a');
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
  
    return 0;
}
