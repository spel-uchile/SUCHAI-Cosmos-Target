# SUCHAI-Cosmos-Target
The following readme its meant to teach how to 
connect the Cosmos software to the SUCHAI-Flight-Software using ZMQ.

##Things to install

the cosmos software is needed to be installed and updated, both of these can be done by following the tutorial in 
https://cosmosrb.com/docs/installation/

Its also needed to have the SUCHAI-Flight-Software found in
https://github.com/spel-uchile/SUCHAI-Flight-Software
<br>

Once this is done, the folder SUCHAI_TARGET must be placed in:
<br>
/cosmos_build/config/targets
<br>
<br>
and the following file must be updated with the new target:
<br>
/cosmos_build/tools/cmd_tlm_server/cmd_tlm_server_chain.txt
<br><br>
To update it, add the following line:
<br>
TARGET SUCHAI_TARGET
 <br><br>
An error may pop up about a missing ruby library. To fix this,
 the txt file "Gemfile" found in the root of cosmos_build, must be modified to compile the new library.

<br>
Adding the following line should fix the bug:
 <br>
gem 'ffi-rzmq'
<br>

##How to run

To connect Cosmos with the FS(Flight Software) you need a terminal running the file
zmqhub.py found in:<br> /SUCHAI-Flight-Software/sandbox/csp_zmq
<br>
You also need a terminal running a build of either the x86 or GROUNDSTATION 
version of the FS (we need it to test the communication).
<br>
After that, just run the command "ruby Launcher" from the root of the cosmos build.
<br>
Once this is done, open the "Command and Telemetry Server".
<br>
Now you can just connect to the SUCHAI_INT interface and test if it works by sending
any message to the node 11 (Cosmos) from the FS.

