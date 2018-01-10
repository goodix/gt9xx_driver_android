## Porting Guide

**Basic Info**

| Supported IC    | GT900 series touch controller |
| --------------- | ----------------------------- |
| I2C address     | 0x5D or 0x14                  |
| Gesture wakeup  | Support                       |
| Stylus          | Support                       |
| Kernel Version  | > 3.10                        |
| Firmware Update | Support                       |

**Simple description of driver files**

`gt9xx.c` (Required): This file contains the most important function such as interrupt handle, touch point report, resume/suspend process and so on.

`gtxx.h` (Required): This file contains the basic structure and macro definition.

`gt9xx_update.c`(Recommended): This file provide firmware update function. If you want support firmware update please compile this file in the driver.

`goodix_tool.c`(Recommended): This file is for debug use. You can add or remove it as you wanted.

`Kconfig`(Required):

`Makefile`(Required):

**Porting step by step**

- copy reference driver folder to $(KER_SRC)/drivers/input/touchscreen/ 

- Modify $(KER_SRC)/drivers/input/touchscreen/Makefile and the following compile command

  ```
  obj-$(CONFIG_TOUCHSCREEN_GT9XX)	+=  gt9xx/
  ```

- Modify $(KER_SRC)/drivers/input/touchscreen/Kconfig and include gt9xx driver kconfig file. 

  ```
  source "drivers/input/touchscreen/gt9xx/Kconfig"
  ```

- Add device tree properties

  You can just copy the following properties into the target device tree with little modify( following dts only contain basic properties for driver to work properly, some extended functionality are removed). Please modify the following properties according you target platform.

  1. I2C address: If the default i2c address (0x5d) conflict with other device you can just change it to 0x14.

  2. reset-gpios: You need assign a reset GPIO for our IC.

  3. irq-gpios: And also an irq GPIO is also needed.

  4. irq-flags: This properties specified the interrupt trigger type. You can set it with the following value

      <1>  rising edge triggered

      <2>  falling edge triggered

  5. touchscreen-max-id: Generally keep the with default value is ok.

  6. touchscreen-size-x: X-axis resolution, need fix according your IC configuration.

  7. touchscreen-size-y: Y-axis resolution, need fix according your IC configuration.

  8. touchscreen-max-w: Generally keep the with default value is ok.

  9. touchscreen-max-p: Generally keep the with default value is ok.

  10. goodix,int-sync: This is property is very for our IC to work properly, please don't modified it. 


  ```
  &i2c0 {
    	gt9xx@5d {
          compatible = "goodix,gt9xx";
          reg = <0x5d>; 
          pinctrl-names = "default", "int-output-low","int-output-high", "int-input";
          pinctrl-0 = <&ts_int_default>;
          pinctrl-1 = <&ts_int_output_low>;
          pinctrl-2 = <&ts_int_output_high>;
          pinctrl-3 = <&ts_int_input>;

          reset-gpios = <&msm_gpio 12 0x0>;
          irq-gpios = <&msm_gpio 13 0x2800>;
          irq-flags = <2>;

          touchscreen-max-id = <11>;
          touchscreen-size-x = <1080>;
          touchscreen-size-y = <1920>;
          touchscreen-max-w = <512>;
          touchscreen-max-p = <512>;

          goodix,int-sync = <1>;
      };
  }
  ```

  Because we use Pinctrl to control irq-gpio state. Please add the following pinctrl state declaration to the target platform device tree. Attention here need fix the irq-gpio number according to the  

  ```
  &msmgpio {               
  	/* add pingrp for touchscreen */
  	ts_int_default: ts_int_defalut {
  		mux {
  			pins = "gpio13";
  			function = "gpio";
  		};
  		config {
  			pins = "gpio13";
  			drive-strength = <16>;
  			/*bias-pull-up;*/
  			input-enable;
  			bias-disable;
  		};
  	};

  	ts_int_output_high: ts_int_output_high {
  		mux {
  			pins = "gpio13";
  			function = "gpio";
  		};
  		config {
  			pins = "gpio13";
  			output-high;
  		};
  	};

  	ts_int_output_low: ts_int_output_low {
  		mux {
  			pins = "gpio13";
  			function = "gpio";
  		};
  		config {
  			pins = "gpio65";
  			output-low;
  		};
  	};

  	ts_int_input: ts_int_input {
  		mux {
  			pins = "gpio13";
  			function = "gpio";
  		};
  		config {
  			pins = "gpio13";
  			input-enable;
  			bias-disable;
  		};
  	};
  };
  ```

  

**Appendix**

This file only introduce the basic requirement for our driver work on a now device. And more detailed information will add later. If have any problem when porting, please mail me.