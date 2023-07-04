#include <stdlib.h>
#include <cstdint>
#include <iostream>
#include <fstream>
#define MAXLEN 100
#ifndef LENGTH
#define LENGTH 3
#endif
int16_t lab1(int16_t a, int16_t b) {
    int16_t mask = 1, ans = 0;  //初始化
    while (b) {     //计算 1 的个数
        if (mask & a)
            ans++;
        mask += mask;
        b--;
    }
    return ans; //返回结果
}
int16_t lab2(int16_t p, int16_t q, int16_t n) {
    int16_t fn = 1, fn_1 = 1;   //初始化
    n--;
    while (n) { //递推计算
        int16_t tmp = 0;
        tmp += fn_1 & (p - 1);  //掩码求余
        int16_t back = fn;
        while (back >= 0)   //递减求余
            back -= q;
        back += q;
        tmp += back;
        fn_1 = fn;  //更新状态
        fn = tmp;
        n--;
    }
    return fn;  //返回结果
}
int16_t lab3(int16_t n, char s[]) {
    int16_t ans = 0, cur_len = 1, cur_char = s[0];  //初始化
    for (int i = 1; i < n; ++i) {   //扫描字符串
        if (s[i] == cur_char)   //相等长度++
            cur_len++;
        else {
            if (cur_len > ans)  //更新最新长度
                ans = cur_len;
            cur_char = s[i];    //更新现在比较的字符
            cur_len = 1;
        }
    }
    if (cur_len > ans)  //最后再更新一次最大长度
        ans = cur_len;
    return ans; //返回结果
}
int16_t lab4(int16_t score[], int16_t *a, int16_t *b) {
    //选择排序，每次找到最小的换到前面
    for (int i = 0; i < 16; ++i) {
        int16_t cur_min = score[i], cur_pos = i;
        for (int j = i + 1; j < 16; ++j) {
            if (score[j] < cur_min) {
                cur_min = score[j];
                cur_pos = j;
            }
        }
        int16_t tmp = score[i];
        score[i] = cur_min;
        score[cur_pos] = tmp;
    }
    //从后向前扫描已排序的score数组，计算AB个数
    *a = *b = 0;
    for (int i = 15; i > 7; --i) {
        if (score[i] >= 85 && i > 11)
            (*a)++;
        else if (score[i] >= 75)
            (*b)++;
        else
            break;
    }
    return 1;
}

int main() {
    std::fstream file;
    file.open("test.txt", std::ios::in);
    //lab1
    int16_t a = 0, b = 0;
    for (int i = 0; i < LENGTH; ++i) {
        file >> a >> b;
        std::cout << lab1(a, b) << std::endl;
    }
    //lab2
    int16_t p = 0, q = 0, n = 0;
    for (int i = 0; i < LENGTH; ++i) {
        file >> p >> q >> n;
        std::cout << lab2(p, q, n) << std::endl;
    }
    //lab3
    char s[MAXLEN];
    for (int i = 0; i < LENGTH; ++i) {
        file >> n >> s;
        std::cout << lab3(n, s) << std::endl;
    }
    //lab4
    int16_t score[16];
    for (int i = 0; i < LENGTH; ++i) {
        for (int j = 0; j < 16; ++j)
            file >> score[j];
        lab4(score, &a, &b);
        for (int j = 0; j < 16; ++j)
            std::cout << score[j] << " ";
        std::cout << std::endl << a << " " << b << std::endl;
    }
    file.close();
    system("pause");
    return 0;
}