# Ultrasound sensor HS-SR04
## Team members
- Emanuel Antol : sensor_read.vhd, hardware setup, Readme file, debugging
- Jan Konkolský : topLevel.vhd, pulse_enable.vhd, debugging
- Vojtěch Trunda : bcd_mux.vhd, debugging, hardware setup
- David Karas : bin_bcd.vhd, Documentation, Readme file

### Project Overview
The objective of this project was to develop a controller for HC-SR04 ultrasonic sensors. After a thorough discussion among all team members, we agreed on a clear implementation goal.

Our aim was to measure distances using two separate HC-SR04 ultrasonic sensors and simultaneously display both measurements in centimeters on two individual seven-segment display "modules". Based on prior experience with the HC-SR04, we were aware that its accuracy decreases near the edges of its measurement range. To address this limitation, we decided to include an error indicator in our system. This indicator notifies the user when a measured distance falls outside the reliable, customizable operating range of the sensor—either too close or too far to be considered accurate or stable.

The following sections describe our final hardware and software solutions designed to meet these objectives.

## Hardware description of demo application
In our application we put the HS-SR04 sensor on the bredboard, which makes it easier for prototyping.
To supply power to the HS-SR04 sensor we used an Arduino, since the Nexys A7 50-T does not support the required 3.3V. We had to use voltage divider, to step down the 5V from Arduino to 3.3V. 
The echo output is connected to the JD3 (JD4 for 2nd sensor) port on the HS-SR04 sensor and the trigger input is connected to the JD1 (JD2 for 2nd sensor).

## Software description
### pulse_enable
The pulse_enable component sends 15 us wide pulse to the HS-SR04‘s trigger pin, which will start measuring proces. This component is dependant on the clock signal. If the clock signal is 0 it will not activate the HS-SR04 sensor.

### sensor_read
The sensor_read component is working as a finite state machine with 3 states (Waiting, Counting, Write) and it is used to measure the width of the pulse received from the HS-SR04’s echo pin, convert it to a binary distance value and sends it to the [bin_bcd](#bin_bcd). The sensor is calibrated to the ambient temperature of 20°C.
If the measured distance is out of bounds, it will activate an error signal. Distance bounds are customizable through genreic component parameters.
![[tb_sensor_readv2.png]](img/tb_sensor_readv2.png)

### bin_bcd
The bin_bcd.vhd component is used to convert the binary distance measured in [sensor_read](#sensor_read.vhd), and convert it to bcd code, which is than further send to [bcd_mux](#bcd_mux.vhd).

We defined two ports: binary_in (for the ) 
We used the shift plus three algorithm to convert the binary value to bcd. The algorithm takes first 4 bits, compares it, if its bigger than 4 in binary. If it is bigger than 4 we add 3 in binary to the bcd_value and continue to the next 4 bits.
![[bin_bcd.png]](img/bin_bcd.png)

### bcd_mux
The bcd_mux component is a multiplexor used to take the input bcd value from 2 sensors and display them on the seven segment display at the same time.
It takes one half of the inputing bcd values and decides, if it should display it on the right or left seven segment display, by enabling cathodes on the Nexys board. 
From this half of the bcd value it takes group of 4 binary values and assigns them to the binary output, which is then used in the [bin2seg](#bin2seg).

![[tb_bcd_mux.png]](img/tb_bcd_mux.png)

This component also incorporates hold function that is used to hold the current displayed value on the display, if we hold the center button. 

### bin2seg
The bin2seg component is used to convert the inputing distance value and display it on the 7 segment display. 

### top_level
The top_level component is used to incorporate all of the components mentioned above, and to connect their inputs and outputs with the corresponding inputs and outputs. 

### clock_en
The clock_en component is used to supply clock signal to components that require clock signal. Components which require clock signal: [pulse_enable](#pulse_enable), [sensor_read](#sensor_read) and [bcd_mux](#bcd_mux) 

## References

1. Inspiration for the bin_bcd component: https://piembsystech.com/binary-to-bcd-conversion-in-vhdl-programming-language/
2. Bin2seg and clock_en components reused from Digital electronics course repository https://github.com/tomas-fryza/vhdl-labs/tree/master
