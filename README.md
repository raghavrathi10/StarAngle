# StarAngle: User Orientation Sensing with Beacon Phase Measurements of Multiple Starlink Satellites(FOR EDUCATION AND ADADEMIC RESEARCH ONLY)

StarAngle estimates user orientation using the beacon signals of Starlink satellites by measuring the beacon phase difference between the two receiving antennas.

This repository contains the source code of StarAngle written in MATLAB along with the GRC sketch used to record the beacon signal using a USRP B210. To test StarAngle, you may download the trace files collected in our experiments and feed them to StarAngle.  Our trace files can be downloaded at https://zenodo.org/records/13881520. 

To run the source code, MATLAB R2023b or above along with the following toolboxes is required: Aerospace toolbox, communications toolbox, curve fitting toolbox, fixed-point designer, satellite communications toolbox and Statistics and Machine Learning Toolbox.

Our trace files were collected in 10 different locations and a different angle was tested at each location. 

Please follow the steps below to successfully setup and run StarAngle

### Step 1 - Instructions to setup the program execution environment:

* Software - MATLAB R2023b with Aerospace toolbox, communications toolbox, curve fitting toolbox, fixed-point designer, satellite communications toolbox and Statistics and Machine Learning Toolbox.
* Storage - Code + Traces 35 GB.
* Setup Time - Less than 1 hour.
* Time to Run - About 2 min to process a trace and about 90 min to process all traces. (With recommended hardware)
* Recommended Hardware - 11th Gen Intel(R) Core(TM) i7-11700 @ 2.50GHz, 8 cores, 16 threads, 56 GB ram, NVIDIA GeForce GT 730 2GB memory.

### Step 2 - Understanding the dataset:

* The entire dataset is available at https://zenodo.org/records/13881520
* The naming of each directory is as follows *"date-location/angle__/"*
* There are 4 types of files present. tle, cfg, mat and data.
  * There are 2 types of *tle* files present, All_sat.tle is the database of all the starlink satellites downloaded before running that particular set of experiments and sig_.tle. Which contains the satellites detected by StarAngle flying above the ground station at the time of experiment.
  * The sig_.cgf file has the following informaiton in the same order
      * Start time of the experiment in UTC, such as 16-Jun-2024 12:22:06
      * Duration of the experiment measured in seconds.
      * Latitude of the experiment measured in degrees.
      * Longitude of the experiment measured in degrees.
      * Azimuth angle of the line connecting the center of the LNBs measured in degrees.
      * Distance between the center of the LNBs measured in meters.
   * The sig__foundbeacons.mat has the variables saved from the workspace after running the particular trace. The purpose of this file is to run StarAngle without running every single function but utilizing the flags mentioned in the program.
   * sig__ant1 and sig__ant2 are the signal capture from antenna 1 and antenna 2 respectively.

### Step 3 - Understanding the functions of StarAngle: 
