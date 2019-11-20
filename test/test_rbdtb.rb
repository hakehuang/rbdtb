#! ruby -I../

require_relative '../lib/rbdtb'
require 'pathname'
require 'minitest/autorun'

class MergeTest < Minitest::Test

  def test_rbdtb_string
    #$log.level = Logger::INFO
    bench_mark = {
      "version" => "/dts-v1/;",
      "root" => {
        "node1" => {
           "a-string-property" => "\"A string\"",
            "child-node2" => "",
            "child-node1" => {
                 "first-child-property" => "",
                    "a-string-property" => "\"Hello, world\"",
                "second-child-property" => "<1>"
            },
            "a-byte-data-property" => "[01 0x23 34 56]",
            "a-string-list-property" => [
                "\"first string\"",
                "\"second string\""
            ]
        },
        "node2" => {
              "a-cell-property" => "<1 2 3 4>",
                  "child-node1" => "",
            "an-empty-property" => ""
        }
      }
    }
    test_string = '''
      /dts-v1/;

      / {
          node1 {
              a-string-property = "A string";
              a-string-list-property = "first string", "second string";
              // hex is implied in byte arrays. no \'0x\' prefix is required
              a-byte-data-property = [01 0x23 34 56];
              child-node1 {
                  first-child-property;
                  second-child-property = <1>;
                  a-string-property = "Hello, world";
              };
              child-node2 {
              };
          };
          node2 {
              a-cell-property = <1 2 3 4>; /* each number (cell) is a uint32 */
              an-empty-property;
              child-node1 {
              };
          };
      };
      '''
      results = dtb_parse_string(test_string)
      assert_equal(bench_mark.to_a, results.to_a)
  end

  def test_rbdtb_file
    bench_mark = {
      "version" => "/dts-v1/;",
      "root" => {
        "compatible" => "\"acme,coyotes-revenge\"",
        "external-bus" => {
          "ethernet@0,0" => {
              "compatible" => "\"smc,smc91c111\""
          },
          "flash@2,0" => {
            "compatible" => [
            "\"samsung,k8f1315ebm\"",
            "\"cfi-flash\""
            ]
          },
          "i2c@1,0" => {
            "compatible" => "\"acme,a1234-i2c-bus\"",
            "rtc@58" => {
              "compatible" => "\"maxim,ds1338\""
            }
          }
        },
        "spi@10115000" => {
          "compatible" => "\"arm,pl022\""
        },
        "interrupt-controller@10140000" => {
          "compatible" => "\"arm,pl190\""
        },
        "gpio@101F3000" => {
          "compatible" => "\"arm,pl061\""
        },
        "serial@101F2000" => {
          "compatible" => "\"arm,pl011\""
        },
        "serial@101F0000" => {
          "compatible" => "\"arm,pl011\""
        },
        "cpus" => {
          "cpu@0" => {
            "compatible" => "\"arm,cortex-a9\""
          },
          "cpu@1" => {
            "compatible" => "\"arm,cortex-a9\""
          }
        }
      }
    }
    results = dtb_parse_file("test/sample.dts_compiled")
    assert_equal(results.to_a, bench_mark.to_a)
  end

  def test_rbdtb_file2
    bench_mark = {
    "version" => "/dts-v1/;",
       "root" => {
         "#address-cells" => "<0x01>",
              "gpio_keys" => {
               "compatible" => "\"gpio-keys\"",
                 "button_1" => {
                "label" => "\"User SW4\"",
                "gpios" => "<0x03 0x05 0x00>"
            },
            "user_button_4" => {
                "button_1" => {
                    "label" => "\"User SW4\"",
                    "gpios" => "<0x03 0x05 0x00>"
                }
            },
                 "button_0" => {
                "label" => "\"User SW3\"",
                "gpios" => "<0x03 0x04 0x00>"
            },
            "user_button_3" => {
                "button_0" => {
                    "label" => "\"User SW3\"",
                    "gpios" => "<0x03 0x04 0x00>"
                }
            }
        },
                   "leds" => {
            "compatible" => "\"gpio-leds\"",
                 "led_2" => {
                "gpios" => "<0x04 0x12 0x00>",
                "label" => "\"User LD3\""
            },
              "blue_led" => {
                "led_2" => {
                    "gpios" => "<0x04 0x12 0x00>",
                    "label" => "\"User LD3\""
                }
            },
                 "led_1" => {
                "gpios" => "<0x04 0x13 0x00>",
                "label" => "\"User LD2\""
            },
             "green_led" => {
                "led_1" => {
                    "gpios" => "<0x04 0x13 0x00>",
                    "label" => "\"User LD2\""
                }
            },
                 "led_0" => {
                "gpios" => "<0x03 0x01 0x00>",
                "label" => "\"User LD1\""
            },
               "red_led" => {
                "led_0" => {
                    "gpios" => "<0x03 0x01 0x00>",
                    "label" => "\"User LD1\""
                }
            }
        },
        "memory@20000000" => {
            "compatible" => "\"mmio-sram\"",
                   "reg" => "<0x20000000 0x20000>"
        },
                  "sram0" => {
            "memory@20000000" => {
                "compatible" => "\"mmio-sram\"",
                       "reg" => "<0x20000000 0x20000>"
            }
        },
                   "cpus" => {
            "#address-cells" => "<0x01>",
                     "cpu@0" => {
                "device_type" => "\"cpu\"",
                        "reg" => "<0x00>",
                 "compatible" => "\"arm,cortex-m0+\""
            },
               "#size-cells" => "<0x00>"
        },
                    "soc" => {
                           "#address-cells" => "<0x01>",
                          "random@40029000" => {
                "compatible" => "\"nxp,kinetis-trng\"",
                     "label" => "\"TRNG\"",
                "interrupts" => "<0x0d 0x00>",
                    "status" => "\"okay\"",
                       "reg" => "<0x40029000 0x1000>"
            },
                                     "trng" => {
                "random@40029000" => {
                    "compatible" => "\"nxp,kinetis-trng\"",
                         "label" => "\"TRNG\"",
                    "interrupts" => "<0x0d 0x00>",
                        "status" => "\"okay\"",
                           "reg" => "<0x40029000 0x1000>"
                }
            },
                             "adc@4003b000" => {
                       "compatible" => "\"nxp,kinetis-adc16\"",
                "#io-channel-cells" => "<0x01>",
                           "status" => "\"okay\"",
                            "label" => "\"ADC_0\"",
                       "interrupts" => "<0x0f 0x00>",
                              "reg" => "<0x4003b000 0x70>"
            },
                                     "adc0" => {
                "adc@4003b000" => {
                           "compatible" => "\"nxp,kinetis-adc16\"",
                    "#io-channel-cells" => "<0x01>",
                               "status" => "\"okay\"",
                                "label" => "\"ADC_0\"",
                           "interrupts" => "<0x0f 0x00>",
                                  "reg" => "<0x4003b000 0x70>"
                }
            },
                             "pwm@4003a000" => {
                "compatible" => "\"nxp,kw41z-pwm\"",
                    "period" => "<0x3e8>",
                 "prescaler" => "<0x02>",
                       "reg" => "<0x4003a000 0x88>"
            },
                                     "pwm2" => {
                "pwm@4003a000" => {
                    "compatible" => "\"nxp,kw41z-pwm\"",
                        "period" => "<0x3e8>",
                     "prescaler" => "<0x02>",
                           "reg" => "<0x4003a000 0x88>"
                }
            },
                             "pwm@40039000" => {
                "compatible" => "\"nxp,kw41z-pwm\"",
                    "period" => "<0x3e8>",
                 "prescaler" => "<0x02>",
                       "reg" => "<0x40039000 0x88>"
            },
                                     "pwm1" => {
                "pwm@40039000" => {
                    "compatible" => "\"nxp,kw41z-pwm\"",
                        "period" => "<0x3e8>",
                     "prescaler" => "<0x02>",
                           "reg" => "<0x40039000 0x88>"
                }
            },
                             "pwm@40038000" => {
                "compatible" => "\"nxp,kw41z-pwm\"",
                    "period" => "<0x3e8>",
                 "prescaler" => "<0x02>",
                       "reg" => "<0x40038000 0x88>"
            },
                                     "pwm0" => {
                "pwm@40038000" => {
                    "compatible" => "\"nxp,kw41z-pwm\"",
                        "period" => "<0x3e8>",
                     "prescaler" => "<0x02>",
                           "reg" => "<0x40038000 0x88>"
                }
            },
                             "spi@4002d000" => {
                    "compatible" => "\"nxp,kinetis-dspi\"",
                   "#size-cells" => "<0x00>",
                "#address-cells" => "<0x01>",
                        "status" => "\"disabled\"",
                        "clocks" => "<0x02 0x02 0x103c 0x0d>",
                         "label" => "\"SPI_1\"",
                    "interrupts" => "<0x1d 0x03>",
                           "reg" => "<0x4002d000 0x9c>"
            },
                                     "spi1" => {
                "spi@4002d000" => {
                        "compatible" => "\"nxp,kinetis-dspi\"",
                       "#size-cells" => "<0x00>",
                    "#address-cells" => "<0x01>",
                            "status" => "\"disabled\"",
                            "clocks" => "<0x02 0x02 0x103c 0x0d>",
                             "label" => "\"SPI_1\"",
                        "interrupts" => "<0x1d 0x03>",
                               "reg" => "<0x4002d000 0x9c>"
                }
            },
                             "spi@4002c000" => {
                    "compatible" => "\"nxp,kinetis-dspi\"",
                   "#size-cells" => "<0x00>",
                "#address-cells" => "<0x01>",
                        "clocks" => "<0x02 0x02 0x103c 0x0c>",
                         "label" => "\"SPI_0\"",
                    "interrupts" => "<0x0a 0x03>",
                           "reg" => "<0x4002c000 0x9c>"
            },
                                     "spi0" => {
                "spi@4002c000" => {
                        "compatible" => "\"nxp,kinetis-dspi\"",
                       "#size-cells" => "<0x00>",
                    "#address-cells" => "<0x01>",
                            "clocks" => "<0x02 0x02 0x103c 0x0c>",
                             "label" => "\"SPI_0\"",
                        "interrupts" => "<0x0a 0x03>",
                               "reg" => "<0x4002c000 0x9c>"
                }
            },
                            "gpio@400ff080" => {
                     "compatible" => "\"nxp,kinetis-gpio\"",
                        "phandle" => "<0x03>",
                    "#gpio-cells" => "<0x02>",
                "gpio-controller" => "",
                          "label" => "\"GPIO_2\"",
                     "interrupts" => "<0x1f 0x02>",
                            "reg" => "<0x400ff080 0x40>"
            },
                                    "gpioc" => {
                "gpio@400ff080" => {
                         "compatible" => "\"nxp,kinetis-gpio\"",
                            "phandle" => "<0x03>",
                        "#gpio-cells" => "<0x02>",
                    "gpio-controller" => "",
                              "label" => "\"GPIO_2\"",
                         "interrupts" => "<0x1f 0x02>",
                                "reg" => "<0x400ff080 0x40>"
                }
            },
                            "gpio@400ff040" => {
                     "compatible" => "\"nxp,kinetis-gpio\"",
                    "#gpio-cells" => "<0x02>",
                "gpio-controller" => "",
                          "label" => "\"GPIO_1\"",
                            "reg" => "<0x400ff040 0x40>"
            },
                                    "gpiob" => {
                "gpio@400ff040" => {
                         "compatible" => "\"nxp,kinetis-gpio\"",
                        "#gpio-cells" => "<0x02>",
                    "gpio-controller" => "",
                              "label" => "\"GPIO_1\"",
                                "reg" => "<0x400ff040 0x40>"
                }
            },
                            "gpio@400ff000" => {
                     "compatible" => "\"nxp,kinetis-gpio\"",
                        "phandle" => "<0x04>",
                    "#gpio-cells" => "<0x02>",
                "gpio-controller" => "",
                          "label" => "\"GPIO_0\"",
                     "interrupts" => "<0x1e 0x02>",
                            "reg" => "<0x400ff000 0x40>"
            },
                                    "gpioa" => {
                "gpio@400ff000" => {
                         "compatible" => "\"nxp,kinetis-gpio\"",
                            "phandle" => "<0x04>",
                        "#gpio-cells" => "<0x02>",
                    "gpio-controller" => "",
                              "label" => "\"GPIO_0\"",
                         "interrupts" => "<0x1e 0x02>",
                                "reg" => "<0x400ff000 0x40>"
                }
            },
                          "pinmux@4004b000" => {
                "compatible" => "\"nxp,kinetis-pinmux\"",
                    "clocks" => "<0x02 0x02 0x1038 0x0b>",
                       "reg" => "<0x4004b000 0xa4>"
            },
                                 "pinmux_c" => {
                "pinmux@4004b000" => {
                    "compatible" => "\"nxp,kinetis-pinmux\"",
                        "clocks" => "<0x02 0x02 0x1038 0x0b>",
                           "reg" => "<0x4004b000 0xa4>"
                }
            },
                          "pinmux@4004a000" => {
                "compatible" => "\"nxp,kinetis-pinmux\"",
                    "clocks" => "<0x02 0x02 0x1038 0x0a>",
                       "reg" => "<0x4004a000 0xa4>"
            },
                                 "pinmux_b" => {
                "pinmux@4004a000" => {
                    "compatible" => "\"nxp,kinetis-pinmux\"",
                        "clocks" => "<0x02 0x02 0x1038 0x0a>",
                           "reg" => "<0x4004a000 0xa4>"
                }
            },
                          "pinmux@40049000" => {
                "compatible" => "\"nxp,kinetis-pinmux\"",
                    "clocks" => "<0x02 0x02 0x1038 0x09>",
                       "reg" => "<0x40049000 0xa4>"
            },
                                 "pinmux_a" => {
                "pinmux@40049000" => {
                    "compatible" => "\"nxp,kinetis-pinmux\"",
                        "clocks" => "<0x02 0x02 0x1038 0x09>",
                           "reg" => "<0x40049000 0xa4>"
                }
            },
                          "lpuart@40054000" => {
                   "compatible" => "\"nxp,kinetis-lpuart\"",
                "current-speed" => "<0x1c200>",
                       "status" => "\"okay\"",
                        "label" => "\"UART_0\"",
                       "clocks" => "<0x02 0x00 0x1038 0x14>",
                   "interrupts" => "<0x0c 0x00>",
                          "reg" => "<0x40054000 0x18>"
            },
                                  "lpuart0" => {
                "lpuart@40054000" => {
                       "compatible" => "\"nxp,kinetis-lpuart\"",
                    "current-speed" => "<0x1c200>",
                           "status" => "\"okay\"",
                            "label" => "\"UART_0\"",
                           "clocks" => "<0x02 0x00 0x1038 0x14>",
                       "interrupts" => "<0x0c 0x00>",
                              "reg" => "<0x40054000 0x18>"
                }
            },
                             "i2c@40067000" => {
                     "compatible" => "\"nxp,kinetis-i2c\"",
                    "fxos8700@1f" => {
                    "compatible" => "\"nxp,fxos8700\"",
                    "int1-gpios" => "<0x03 0x01 0x00>",
                         "label" => "\"FXOS8700\"",
                           "reg" => "<0x1f>"
                },
                         "status" => "\"okay\"",
                          "label" => "\"I2C_1\"",
                         "clocks" => "<0x02 0x00 0x1034 0x07>",
                     "interrupts" => "<0x09 0x00>",
                            "reg" => "<0x40067000 0x1000>",
                    "#size-cells" => "<0x00>",
                 "#address-cells" => "<0x01>",
                "clock-frequency" => "<0x186a0>"
            },
                                     "i2c1" => {
                "i2c@40067000" => {
                         "compatible" => "\"nxp,kinetis-i2c\"",
                        "fxos8700@1f" => {
                        "compatible" => "\"nxp,fxos8700\"",
                        "int1-gpios" => "<0x03 0x01 0x00>",
                             "label" => "\"FXOS8700\"",
                               "reg" => "<0x1f>"
                    },
                             "status" => "\"okay\"",
                              "label" => "\"I2C_1\"",
                             "clocks" => "<0x02 0x00 0x1034 0x07>",
                         "interrupts" => "<0x09 0x00>",
                                "reg" => "<0x40067000 0x1000>",
                        "#size-cells" => "<0x00>",
                     "#address-cells" => "<0x01>",
                    "clock-frequency" => "<0x186a0>"
                }
            },
                             "i2c@40066000" => {
                     "compatible" => "\"nxp,kinetis-i2c\"",
                         "status" => "\"disabled\"",
                          "label" => "\"I2C_0\"",
                         "clocks" => "<0x02 0x02 0x1034 0x06>",
                     "interrupts" => "<0x08 0x00>",
                            "reg" => "<0x40066000 0x1000>",
                    "#size-cells" => "<0x00>",
                 "#address-cells" => "<0x01>",
                "clock-frequency" => "<0x186a0>"
            },
                                     "i2c0" => {
                "i2c@40066000" => {
                         "compatible" => "\"nxp,kinetis-i2c\"",
                             "status" => "\"disabled\"",
                              "label" => "\"I2C_0\"",
                             "clocks" => "<0x02 0x02 0x1034 0x06>",
                         "interrupts" => "<0x08 0x00>",
                                "reg" => "<0x40066000 0x1000>",
                        "#size-cells" => "<0x00>",
                     "#address-cells" => "<0x01>",
                    "clock-frequency" => "<0x186a0>"
                }
            },
                "flash-controller@40020000" => {
                    "compatible" => "\"nxp,kinetis-ftfa\"",
                       "flash@0" => {
                          "compatible" => "\"soc-nv-flash\"",
                    "write-block-size" => "<0x04>",
                    "erase-block-size" => "<0x800>",
                                 "reg" => "<0x00 0x80000>",
                               "label" => "\"MCUX_FLASH\""
                },
                        "flash0" => {
                    "flash@0" => {
                              "compatible" => "\"soc-nv-flash\"",
                        "write-block-size" => "<0x04>",
                        "erase-block-size" => "<0x800>",
                                     "reg" => "<0x00 0x80000>",
                                   "label" => "\"MCUX_FLASH\""
                    }
                },
                   "#size-cells" => "<0x01>",
                "#address-cells" => "<0x01>",
                    "interrupts" => "<0x05 0x00>",
                           "reg" => "<0x40020000 0x2c>",
                         "label" => "\"FLASH_CTRL\""
            },
                             "sim@40047000" => {
                  "compatible" => "\"nxp,kinetis-sim\"",
                     "phandle" => "<0x02>",
                "#clock-cells" => "<0x03>",
                       "label" => "\"SIM\"",
                         "reg" => "<0x40047000 0x1060>"
            },
                                      "sim" => {
                "sim@40047000" => {
                      "compatible" => "\"nxp,kinetis-sim\"",
                         "phandle" => "<0x02>",
                    "#clock-cells" => "<0x03>",
                           "label" => "\"SIM\"",
                             "reg" => "<0x40047000 0x1060>"
                }
            },
                             "rtc@4003d000" => {
                     "compatible" => "\"nxp,kinetis-rtc\"",
                      "prescaler" => "<0x8000>",
                          "label" => "\"RTC_0\"",
                "clock-frequency" => "<0x8000>",
                     "interrupts" => "<0x14 0x00>",
                            "reg" => "<0x4003d000 0x20>"
            },
                                     "rtc0" => {
                "rtc@4003d000" => {
                         "compatible" => "\"nxp,kinetis-rtc\"",
                          "prescaler" => "<0x8000>",
                              "label" => "\"RTC_0\"",
                    "clock-frequency" => "<0x8000>",
                         "interrupts" => "<0x14 0x00>",
                                "reg" => "<0x4003d000 0x20>"
                }
            },
                "clock-controller@40065000" => {
                               "compatible" => "\"nxp,kw41z-osc\"",
                "enable-external-reference" => "",
                                      "reg" => "<0x40065000 0x04>"
            },
                "clock-controller@40064000" => {
                "compatible" => "\"nxp,kw41z-mcg\"",
                       "reg" => "<0x40064000 0x13>"
            },
                                      "mcg" => {
                "clock-controller@40064000" => {
                    "compatible" => "\"nxp,kw41z-mcg\"",
                           "reg" => "<0x40064000 0x13>"
                }
            },
                           "timer@e000e010" => {
                "compatible" => "\"arm,armv6m-systick\"",
                    "status" => "\"disabled\"",
                       "reg" => "<0xe000e010 0x10>"
            },
                                  "systick" => {
                "timer@e000e010" => {
                    "compatible" => "\"arm,armv6m-systick\"",
                        "status" => "\"disabled\"",
                           "reg" => "<0xe000e010 0x10>"
                }
            },
            "interrupt-controller@e000e100" => {
                               "compatible" => "\"arm,v6m-nvic\"",
                                  "phandle" => "<0x01>",
                "arm,num-irq-priority-bits" => "<0x02>",
                         "#interrupt-cells" => "<0x02>",
                     "interrupt-controller" => "",
                                      "reg" => "<0xe000e100 0xc00>"
            },
                                     "nvic" => {
                "interrupt-controller@e000e100" => {
                                   "compatible" => "\"arm,v6m-nvic\"",
                                      "phandle" => "<0x01>",
                    "arm,num-irq-priority-bits" => "<0x02>",
                             "#interrupt-cells" => "<0x02>",
                         "interrupt-controller" => "",
                                          "reg" => "<0xe000e100 0xc00>"
                }
            },
                                   "ranges" => "",
                         "interrupt-parent" => "<0x01>",
                               "compatible" => "\"simple-bus\"",
                              "#size-cells" => "<0x01>"
        },
                "aliases" => {
               "adc-0" => "\"/soc/adc@4003b000\"",
               "rtc-0" => "\"/soc/rtc@4003d000\"",
                 "sw1" => "\"/gpio_keys/button_1\"",
                 "sw0" => "\"/gpio_keys/button_0\"",
                "led2" => "\"/leds/led_0\"",
                "led1" => "\"/leds/led_2\"",
                "led0" => "\"/leds/led_1\"",
               "i2c-1" => "\"/soc/i2c@40067000\"",
               "i2c-0" => "\"/soc/i2c@40066000\"",
              "gpio-c" => "\"/soc/gpio@400ff080\"",
              "gpio-b" => "\"/soc/gpio@400ff040\"",
              "gpio-a" => "\"/soc/gpio@400ff000\"",
            "pinmux-c" => "\"/soc/pinmux@4004b000\"",
            "pinmux-b" => "\"/soc/pinmux@4004a000\"",
            "pinmux-a" => "\"/soc/pinmux@40049000\"",
            "lpuart-0" => "\"/soc/lpuart@40054000\""
        },
                 "chosen" => {
                  "zephyr,sram" => "\"/memory@20000000\"",
            "zephyr,shell-uart" => "\"/soc/lpuart@40054000\"",
               "zephyr,console" => "\"/soc/lpuart@40054000\"",
                 "zephyr,flash" => "\"/soc/flash-controller@40020000/flash@0\""
        },
             "compatible" => [
            "\"nxp,kw41z\"",
            "\"nxp,mkw41z4\""
        ],
                  "model" => "\"NXP Freedom KW41Z board\"",
            "#size-cells" => "<0x01>"
      }
    }
    results = dtb_parse_file("test/frdm_kw41z.dts_compiled")
    assert_equal(results.to_a, bench_mark.to_a)
  end

end