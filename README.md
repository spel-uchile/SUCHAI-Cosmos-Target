# SUCHAI-Cosmos-Target
The following readme its meant to teach how to 
connect the Cosmos software to the SUCHAI-Flight-Software using ZMQ.

## Installation

the cosmos software is needed to be installed and updated, both of these can be done by following the tutorial in 
https://cosmosrb.com/docs/installation/

Its also needed to have the SUCHAI-Flight-Software found in
https://github.com/spel-uchile/SUCHAI-Flight-Software


Once this is done, the folder SUCHAI_TARGET must be placed in:

/cosmos_build/config/targets

An error may pop up about a missing ruby library. To fix this,
 the txt file "Gemfile" found in the root of cosmos_build, must be modified to compile the new library.

Adding the following line should fix the bug:

gem 'ffi-rzmq'


## How to run

To connect Cosmos with the FS(Flight Software) you need a terminal running the file
zmqhub.py found in:<br> /SUCHAI-Flight-Software/sandbox/csp_zmq

You also need a terminal running a build of either the x86 or GROUNDSTATION 
version of the FS (we need it to test the communication).

After that, just run the command "ruby Launcher" from the root of the cosmos build.

Once this is done, open the "Command and Telemetry Server".

Now you can just connect to the SUCHAI_INT interface and test if it works by sending
any message to the node 11 (Cosmos) from the FS.

## How to use

To use the COSMOS software effectively once the Launcher is open, you have to navigate to the following tools:

### Command and Telemetry Server: 

it has to be open since this is the tool that connect the FS to every function of Cosmos. From here the packets sent and received can be inspected

### Command Sender:

COSMOS has the list of all the commands from the FS in it and, from here they can be launched once the server is connected from the "Command and Telemetry Server".

Notice that if you try to launch a command that receive multiples parameters, there will be a "SPACE_X" parameter. This parameter is used to add spaces between the parameters and shouldn't be modified

### Telemetry Viewer:

In the "Telemetry Viewer" can be found different interfaces that show data received from the sattelite. In this particular case, a Control Panel was built using the Telemetry Viewer and should be used to control the requests of data and the control of it.

The following are the explanations for all the screens built:

#### SUCHAI_CONTROL_PANEL:

A Control Panel where all the information from the satellite can be controlled via different tabs displaying different data extracted from each sensor. <b>This screen should be open at all time when operating the satellite</b>.

From this Interface screenshots that are sent to "Cosmos/outputs/logs" can be taken, specific commands that update the info of each tab can be sent and, there is an incorporated script runner to run them from here instead of the "Script runner" tool.

It should be noted that even though the scripts are "run" from this panel, the Script runner will open anyway to run them.

#### SUCHAI_"anything"

Any screen named SUCHAI_"anything" besides the SUCHAI_CONTROL_PANEL are the differents tabs of the Control Panel built as individual interfaces.

This was done so the operator can see multiples tabs at the same time if its needed. There is no difference between opening these screens and opening the same tab from the Control Panel

### Telemetry Grapher:

This tool allows for telemetry items to be added to graphs in groups or by themselves. It also allows for multiple graphs displaying at the same time.

The graphs made in this tool are more detailed than the ones in the Control Panel and therefore, should be used in conjunction with the Control Panel.

There are currently some setups saved of useful graphs configurations.

### Script Runner:

COSMOS as is written in "Ruby" has this tool that is capable of running any Ruby code using the specific methods that COSMOS provides to use packets or commands into the code.

It can run for example, a series of commands and check between them if the returned values are consistent with what they should be or , raise errors or warnings if anything behaves abnormally

If the only thing the script runner is doing is run a series of commands and nothing else, the "Command Sequence" is recommended. 

### Command Sequence:

This tool allow to save sequence of commands so they can be executed with or without delay between them.

There are already some command sequences saved for further use.

## For any further development:

For any further coding and development of the SUCHAI_TARGET it is strongly recommended that the "Config Editor" tool is used to check the methods and keywords innate from COSMOS, this tool provides some documentation and help to complete missing fields.

### Useful links:

https://www.rubydoc.info/gems/cosmos/3.1.1/Cosmos/
<br>
https://cosmosrb.com/docs/system/
<br>
https://github.com/BallAerospace/COSMOS


