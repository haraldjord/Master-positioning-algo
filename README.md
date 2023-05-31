# Master-positioning-algo

This repository contains a MATLAB script that reads data from a serial port, performs Time Difference of Arrival (TDoA) calculations, and visualizes the results. The script connects to a specified serial port, receives data, saves it to local files, and processes the data to calculate TDoA position of fish tag.

# Serial Port Setup
The script begins by setting up the serial port connection. The serialport function is used to create a connection to the specified serial port at a baud rate of 9600. Make sure to modify the serial port name (COM3) and the baud rate if needed to match your setup.

# Node Struct Initialization
The script initializes a node structure (node) that stores the data received from different devices. The structure includes fields for each device, such as GPS information, tag detections, timestamps, and positions. The structure allows for easy organization and access of the received data.

# Figure Initialization
A figure (fig1) is initialized to visualize the data. The figure displays a scatter plot in a 3D coordinate system. The coordinates represent the position of detected tags from different devices. The figure is set up to dynamically update as new data is received.

# Reading and Processing Data
The script enters a while loop to continuously read data from the serial port. The received data is saved to log files and processed to extract relevant information. The data is then stored in the node structure (node) based on the device ID and the type of data received (GPS information or tag detection).

# TDoA Calculation and Visualization
When tag detections are received from all devices (ID1, ID2, ID3), the script performs TDoA calculations. It verifies the last tag detection timestamps, calculates the time differences between the devices (T21 and T31), and checks for synchronization. If the synchronization conditions are met, the script proceeds to calculate the TDoA and visualizes the results by updating the scatter plot in the figure (fig1).

# Saving Data
The script saves the received data to log files (ID1_log.txt, ID2_log.txt, ID3_log.txt) for future reference and analysis. The log files store the raw data received from the serial port.

