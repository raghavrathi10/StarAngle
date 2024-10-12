# StarAngle: User Orientation Sensing with Beacon Phase Measurements of Multiple Starlink Satellites(FOR EDUCATION AND ADADEMIC RESEARCH ONLY)

StarAngle estimates user orientation using the beacon signals of Starlink satellites by measuring the beacon phase difference between the two receiving antennas.

This repository contains the source code of StarAngle written in MATLAB along with the GRC sketch used to record the beacon signal using a USRP B210. To test StarAngle, you may download the trace files collected in our experiments and feed them to StarAngle.  Our trace files can be downloaded at https://zenodo.org/records/13881520. 

To run the source code, MATLAB R2023b or above along with the following toolboxes is required: Aerospace toolbox, communications toolbox, curve fitting toolbox, fixed-point designer, satellite communications toolbox and Statistics and Machine Learning Toolbox.

Our trace files were collected in 10 different locations and a different angle was tested at each location. 

Please follow the steps below to successfully setup and run StarAngle

### **Step 1 - Instructions to setup the program execution environment:**

* Software - MATLAB R2023b with Aerospace toolbox, communications toolbox, curve fitting toolbox, fixed-point designer, satellite communications toolbox and Statistics and Machine Learning Toolbox.
* Storage - Code + Traces 35 GB.
* Setup Time - Less than 1 hour.
* Time to Run - About 2 min to process a trace and about 90 min to process all traces. (With recommended hardware)
* Recommended Hardware - 11th Gen Intel(R) Core(TM) i7-11700 @ 2.50GHz, 8 cores, 16 threads, 56 GB ram, NVIDIA GeForce GT 730 2GB memory.

### **Step 2 - Understanding the dataset

* The entire dataset is available at https://zenodo.org/records/13881520
