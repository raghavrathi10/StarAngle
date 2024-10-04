# StarAngle: User Orientation Sensing with Beacon Phase Measurements of Multiple Starlink Satellites(FOR EDUCATION AND ADADEMIC RESEARCH ONLY)

StarAngle estimates user orientation using the beacon signals of Starlink satellites by measuring the beacon phase difference between the two receiving antennas.

This repository contains the source code of StarAngle written in MATLAB along with the GRC sketch used to record the beacon signal using a USRP B210. To test StarAngle, you may download the trace files collected in our experiments and feed them to StarAngle.  Our trace files can be downloaded at https://zenodo.org/records/13881520. 

To run the source code, MATLAB R2023b or above along with the following toolboxes is required: Aerospace toolbox, communications toolbox, curve fitting toolbox, fixed-point designer, satellite communications toolbox and Statistics and Machine Learning Toolbox.

Our trace files were collected in 10 different locations and a different angle was tested at each location. 
