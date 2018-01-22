# Aurora Space Program v1.6.4

Modular of scripts to launch a ship in a set program.
## 1. Installation
You will need kOS mod. Put the scripts inside "Kerbal Space Program\Ships\Script".
You will need to i**nstall thermometer, accelerometer and gravioli detector** on a craft for the script to run.

## 2. Program creation
To create a new program, run this command: ```RUN "0:program/Creator".```
Newly created program will be saved in 0:program/*program name*.json

## 3. Running Aurora
Aurora is pretty resource intensive and it's advised to change the config of kOS to above **1000 instructions per update** inside the game difficulty settings.
To start Aurora, add a kOS processor and use Aurora.ks as a boot file or use ```COPYPATH("0:boot/Aurora", "!1:"). RUN Aurora.``` command on a launchpad.
Choose a **program** and a target vessel. All of the selections are saved locally on the craft at volume 1: as well as current craft state, phase etc. so **you can leave a vessel and come back to it later, the program will start where it last left off.**
After confirming a program, vessel will get a unique ID alongside the crafts name. Upon completing the program, the crafts name will be added to the src program, so you can target it on the next rocket launch in the same program.
 
If you want to use the Journal module, make sure to have a lot of disk space on a craft.
## 4.  Journal and Inspector
Journal modules saves craft telemetry every 3 seconds after the launch on volume 1: and if there is a connection to KSC, also in  0: flightlogs.
Inspector is an electron app to open the flightlogs.