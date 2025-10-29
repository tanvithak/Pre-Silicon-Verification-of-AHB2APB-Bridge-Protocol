This repository deals with the Pre-Silicon Verification of ARM based AMBA AHB to APB Bridge Protocol. 

ECE506_Testplan : This file tells about the testplan environment

As mentioned in the testplan document, there are two agents one for AHB and the other for APB. 

The components which are different for the AHB and APB:
-> Interface
-> Sequence
-> Sequence item
-> Sequencer
-> Driver
-> Monitor
-> Agent

The common components:
-> Scoreboard
-> Environment
-> Test

"The design files are passed from Maven Silicon by the author Susmitha Nayak."

The design has AHB as Master and APB as Slave[Specifically 1 AHB Master and 4 APB Slaves]. 
