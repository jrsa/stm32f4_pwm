#include <stm32f4xx.h> 

int main() {
    // enable GPIOA and TIM2
    RCC->AHB1ENR |= RCC_AHB1ENR_GPIOAEN;
    RCC->APB1ENR |= RCC_APB1ENR_TIM2EN;

    GPIOA->MODER |= 0x2; // PA0 in alternate function mode

    // clear pin 0 (first bit) alternate function and
    // initialize to AF01 (TIM2 CH1)
    GPIOA->AFR[0] |= (uint8_t)1;

    // configure timer
    TIM2->PSC = 1000; // clear prescaler
    TIM2->ARR = 200; // set period (Auto Reload Register)

    // configure capture/compare 1
    TIM2->CCMR1 |= 0x60; // PWM1 mode
    TIM2->CCR1 = 100; // pulse width in cycles
    TIM2->CCER |= 1;  // enable cc1

    // enable TIM1
    TIM2->CR1 |= TIM_CR1_CEN;

    while(1);
}