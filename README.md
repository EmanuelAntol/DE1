# Ultrasound sensor controller HS-SR04
## Team members
- Emanuel Antol : sensor_read.vhd, Hardware setup, Debugging, Readme file
- Jan Konkolský : topLevel.vhd, pulse_enable.vhd, Debugging
- Vojtěch Trunda : bcd_mux.vhd, Debugging, Hardware setup
- David Karas : bin_bcd.vhd, Documentation, Readme file

### Project Overview
The objective of this project was to develop a controller for HC-SR04 ultrasonic sensors. After a thorough discussion among all team members, we agreed on a clear implementation goal.

Our aim was to measure distances using two separate HC-SR04 ultrasonic sensors and simultaneously display both measurements in centimeters on two individual seven-segment display "modules". Based on prior experience with the HC-SR04, we were aware that its accuracy decreases near the edges of its measurement range. To address this limitation, we decided to include an error indicator in our system. This indicator notifies the user when a measured distance falls outside the reliable, customizable operating range of the sensor—either too close or too far to be considered accurate or stable.

The following sections describe our final hardware and software solutions designed to meet these objectives.

## Hardware Setup and Sensor Integration

For background functionality, we used the Nexys A7-50T FPGA development board, while an Arduino UNO served as a power supply for the HC-SR04 sensors, since the Nexys A7-50T does not provide the required 5V output. A breadboard was used to connect all components, as it simplifies prototyping and testing.

Because the HC-SR04's "echo" pin outputs a 5V signal—exceeding the voltage tolerance of the Nexys A7-50T—we implemented a voltage divider to step the signal down to a safe level.

For final testing, the following configuration was used (see images below):
The "echo" output pin of the first sensor was connected to port JD3 (JD4 for the second sensor), while the "trigger" input was connected to JD1 (JD2 for the second sensor) on the Nexys A7-50T development board.

<p align="center">
  <img src="img/HW/PXL_20250424_115744207.jpg" width="64%" style="display: inline-block;"/>
  <img src="img/HW/ultrasonic_resistors.jpg" width="35%" style="display: inline-block;"/>
</p>


## Software Architecture and Implementation

To support efficient testing and collaboration, we designed the software to be as modular as possible.  
This modular approach allowed for individual components to be developed and tested independently, which proved instrumental in identifying and resolving bugs during the final top-level integration.
It also makes our solution easily adaptable to support more or fewer sensors (and displays).

The software solution is divided into three main parts to clearly illustrate its functionality:

1. **Sensor Reading and Supporting Components**  
     - Responsible for interfacing with the HC-SR04 ultrasonic sensors and handling the timing logic required to measure and convert pulse widths into distance values (in cm) accurately. It also includes error indication for distances that fall outside the reliable operating range.
     - Components: sensor_readv2.vhd, pulse_enable.vhd, clock_en.vhd

2. **Data Conversion**  
     - Converts binary distance values into BCD format suitable for driving seven-segment displays.
     - Components: bin_bcd.vhd

3. **Data Displaying**  
     - Manages multiplexing of the output to the seven-segment displays, ensuring that all sensor measurements are shown simultaneously and without visible flickering.
     - Components: bcd_mux.vhd, bin2seg.vhd, clock_en.vhd
  
The following section describes the individual components of the final software implementation.

### Top_level
The <code>top_level</code> component is used to integrate all individual modules and connect their inputs and outputs to the corresponding pins on the development board. It also defines the generic parameters for all applicable components. You can see all the individual components in the top_level diagram, in the image below.

You can find the code for this component <a href="source/UltraSonicSensorNew/UltraSonicSensorNew.srcs/sources_1/imports/src_new_new/top_level.vhd">here</a>.

<img src="img/Schema.png">

### sensor_read

The `sensor_readv2` component functions as a finite state machine with three states: **Waiting**, **Counting**, and **Write**. It is responsible for measuring the width of the pulse received from the HS-SR04’s echo pin, converting it into a binary distance value, and sending it to the [bin_bcd](#bin_bcd) component. The sensor is calibrated to an ambient temperature of 20°C, although this can be easily adjusted.

The component also includes an echo signal synchronizer and a "debouncer" to ensure accurate readings from the sensor, even when the falling or leading edges of the echo signal are distorted.

If the measured distance falls outside the acceptable range, the component will trigger an error signal. Distance bounds are customizable through generic component parameters. Specific software mechanisms for this component are documented in comments directly within the source <a href="source/UltraSonicSensorNew/UltraSonicSensorNew.srcs/sources_1/imports/src_new_new/Sensor_readv2.vhd">file</a>.

![[tb_sensor_readv2.png]](img/tb_sensor_readv2.png)

### bin_bcd

The <code>bin_bcd.vhd</code> component is used to convert the binary distance measured in the <a href="#sensor_read">sensor_read</a> component into BCD code. This BCD code is then sent to the <a href="#bcd_mux">bcd_mux</a> component. By converting the binary value to BCD, further logic can directly work with the digits that will be displayed on the seven-segment display, simplifying the complexity of code in subsequent components.

To convert the binary value to BCD, we used the <strong>Shift-Plus-Three</strong> algorithm. The algorithm processes the first 4 bits of the binary value and compares them to see if they are greater than 4 (in binary). If the value is greater than 4, we add 3 (in binary) to the <code>bcd_value</code> and then proceed to the next 4 bits.  

You can find the code for this component <a href="source/UltraSonicSensorNew/UltraSonicSensorNew.srcs/sources_1/imports/src_new_new/bin_bcd.vhd">here</a>, and a reference to the algorithm [here](#References).

![[bin_bcd.png]](img/bin_bcd.png)

### bcd_mux

The <code>bcd_mux</code> component is a multiplexer used to take the input BCD values from the sensors and display them on the seven-segment display "modules" simultaneously. It processes part of the input BCD values and determines which display "module" the data will be shown on by enabling the corresponding cathodes on the Nexys board.  

From this portion of the BCD value, the <code>bcd_mux</code> extracts a group of 4 binary values and assigns them to the binary output. This output is then passed to the <a href="#bin2seg">bin2seg</a> component for further processing.

This component also includes a <strong>hold</strong> function, which allows the currently displayed value to be retained on the display when the center button is held.

You can find the code for this component <a href="source/UltraSonicSensorNew/UltraSonicSensorNew.srcs/sources_1/imports/src_new_new/bcd_mux.vhd">here</a>.

![[tb_bcd_mux.png]](img/tb_bcd_mux.png)

### bin2seg

The <code>bin2seg</code> component is used to convert the input binary distance value and display it on the seven-segment display.

This component was created as part of the digital electronics classes. You can find the code for this component <a href="source/UltraSonicSensorNew/UltraSonicSensorNew.srcs/sources_1/imports/src_new_new/bin2seg.vhd">here</a>, and a reference to the Digital Electronics course [here](#References).

### pulse_enable

The <code>pulse_enable</code> component sends a 15 µs wide pulse to the HS-SR04's trigger pin, initiating the measurement process. This component is activated at regular intervals by a signal from the [clock_enable](#clock_enable) component.

You can find the code for this component <a href="source/UltraSonicSensorNew/UltraSonicSensorNew.srcs/sources_1/imports/src_new_new/pulse_enable.vhd">here</a>.

### clock_en

The <code>clock_en</code> component is used to supply reduced clock signal to components that require it. These components include: <a href="#pulse_enable">pulse_enable</a>, <a href="#sensor_read">sensor_read</a>, and <a href="#bcd_mux">bcd_mux</a>.

This component was created as part of the digital electronics classes. You can find the code for this component <a href="source/UltraSonicSensorNew/UltraSonicSensorNew.srcs/sources_1/imports/src_new_new/clock_en.vhd">here</a>, and a reference to the Digital Electronics course [here](#References).

## References

1. Inspiration for the bin_bcd component: https://piembsystech.com/binary-to-bcd-conversion-in-vhdl-programming-language/
2. Bin2seg and clock_en components reused from Digital electronics course repository: https://github.com/tomas-fryza/vhdl-labs/tree/master
3. OpenAI's ChatGPT was used to generate testing data and simplify documentation creation: https://openai.com/
4. Ultrasonic Ranging Module HC - SR04: https://cdn.sparkfun.com/datasheets/Sensors/Proximity/HCSR04.pdf
5. Online VHDL Testbench Template Generator: https://vhdl.lapinoo.net/ 
