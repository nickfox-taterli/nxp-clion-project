#include "board.h"
#include "fsl_gpio.h"

#include "pin_mux.h"
#include <stdbool.h>
/*******************************************************************************
 * Definitions
 ******************************************************************************/

#define APP_BOARD_TEST_LED_PORT 2U
#define APP_BOARD_TEST_LED_PIN 2U
#define APP_SW_PORT 0U
#define APP_SW_PIN 6U

/*******************************************************************************
 * Prototypes
 ******************************************************************************/

/*******************************************************************************
 * Variables
 ******************************************************************************/
volatile uint32_t g_systickCounter;

/*******************************************************************************
 * Code
 ******************************************************************************/
void SysTick_Handler(void)
{
    if (g_systickCounter != 0U)
    {
        g_systickCounter--;
    }
}

void SysTick_DelayTicks(uint32_t n)
{
    g_systickCounter = n;
    while (g_systickCounter != 0U)
    {
    }
}

/*!
 * @brief Main function
 */
int main(void)
{
    uint32_t port_state = 0;

    /* Define the init structure for the output LED pin*/
    gpio_pin_config_t led_config = {
        kGPIO_DigitalOutput,
        0,
    };

    BOARD_InitPins();
    BOARD_BootClockPLL180M();
    /* Init output LED GPIO. */
    GPIO_PortInit(GPIO, APP_BOARD_TEST_LED_PORT);
    GPIO_PortInit(GPIO, APP_SW_PORT);
    GPIO_PinInit(GPIO, APP_BOARD_TEST_LED_PORT, APP_BOARD_TEST_LED_PIN, &led_config);
    GPIO_PinWrite(GPIO, APP_BOARD_TEST_LED_PORT, APP_BOARD_TEST_LED_PIN, 1);

    /* Port masking */
    GPIO_PortMaskedSet(GPIO, APP_BOARD_TEST_LED_PORT, 0x0000FFFF);
    GPIO_PortMaskedWrite(GPIO, APP_BOARD_TEST_LED_PORT, 0xFFFFFFFF);
    port_state = GPIO_PortRead(GPIO, APP_BOARD_TEST_LED_PORT);
    port_state = GPIO_PortMaskedRead(GPIO, APP_BOARD_TEST_LED_PORT);

    /* Set systick reload value to generate 1ms interrupt */
    if (SysTick_Config(SystemCoreClock / 1000U))
    {
        while (1)
        {
        }
    }

    while (1)
    {
        // port_state = GPIO_PortRead(GPIO, APP_SW_PORT);
        // if (!(port_state & (1 << APP_SW_PIN)))
        // {
            GPIO_PortToggle(GPIO, APP_BOARD_TEST_LED_PORT, 1u << APP_BOARD_TEST_LED_PIN);
        // }
        /* Delay 1000 ms */
        SysTick_DelayTicks(1000U);
    }
}
