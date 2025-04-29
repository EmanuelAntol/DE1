# Ultrasound senzor HS-SR04
## Team members
- Emanuel Antol : Team leader, sensor_read.vhd
- Jan Konkolský : topLevel.vhdl, pulse_enable.vhd
- Vojtěch Trunda : bcd_mux.vhd, debugging
- David Karas : bin_bcd.vhd, Documentation

### Abstract
---


The goal of this project was to measure distance from two separate HS-SR04 ultrasound sensors, and display them on two seven-segment displays at the same time. For background functions we used the Nexys A7 50-T and Arduino UNO as a power supply for the HS-SR04 sensor, as the Nexys A7 50-5 does not support the 3.3V output.

If the measured distance is higher (or lower) than the ultrasound is able to measure, a red diod will light up. According to the datasheet, the distance range which the sensor is able to correctly measure is from 2 cm to 400 cm.




## Hardware description of demo application
---




## Software description
---


### pulse_enable.vhd
The pulse_enable component sends 15 ns wide pulse to the HS-SR04‘s trigger pin, which will start measuring proces. This component is dependant on the clock signal. If the clock signal is 0 it will not activate the HS-SR04 sensor.

### sensor_read.vhd
The sensor_read component is working as a finite state machine with 3 states (Waiting, Counting, Write) and it is used to measure the width of the pulse received from the HS-SR04’s echo pin, convert it to a binary distance value and sends it to the [#bin_bcd.vhd](#bin_bcd.vhd). The sensor is calibrated to the ambient temperature of 20°C.
If the measured distance is out of bounds, it will activate an error diode. 

### bin_bcd.vhd
The bin_bcd.vhd component is used to convert the binary distance measured in [#sensor_read.vhd](#sensor_read.vhd), and convert it to bcd code, which is than further send to [#bcd_mux.vhd](#bcd_mux.vhd).

We defined two ports: binary_in (for the ) 
We used the shift plus three algorithm to convert the binary value to bcd. The algorithm takes first 4 bits, compares it, if its bigger than 4 in binary. If it is bigger than 4 we add 3 in binary to the bcd_value and continue to the next 4 bits.

### bcd_mux.vhd
The bcd_mux component is a multiplexor used to take the input bcd value from 2 sensors and display them on the seven segment display at the same time.
It takes one half of the inputing bcd values and decides, if it should display it on the right or left seven segment display, by enabling cathodes on the Nexys board. 
From this half of the bcd value it takes group of 4 binary values and assigns them to the binary output, which is then used in the [#bin2seg.vhd](#bin2seg.vhd).

![[tb_bcd_mux.png]](img/tb_bcd_mux.png)

This component also incorporates hold function that is used to hold the current displayed value on the display, if we hold the center button. 

### bin2seg.vhd
The bin2seg component is used to convert the inputing distance value and display it on the 7 segment display. 

### top_level.vhd
The top_level component is used to incorporate all of the components mentioned above, and to connect their inputs and outputs with the corresponding inputs and outputs. 

## References
___

1. Inspiration for the bin_bcd component: https://piembsystech.com/binary-to-bcd-conversion-in-vhdl-programming-language/
2. ...