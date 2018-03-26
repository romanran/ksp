# Aurora Space Program v2.0.2

Modular of scripts to launch a ship in a set program.
## 1. Installation
You will need kOS mod. Put the scripts inside "Kerbal Space Program\Ships\Script".
You will need to **install thermometer, accelerometer and gravioli detector** on a craft for the script to run.

## 2. Program creation
To create a new program, run this command: ```RUN "0:program/Creator".```
Newly created program will be saved in 0:program/*program name*.json

## 3. Running Aurora
Aurora is pretty resource intensive and it's advised to change the config of kOS to above **1000 instructions per update** inside the game difficulty settings.
To start Aurora, add a kOS processor and use Aurora.ks as a boot file or use ```COPYPATH("0:boot/Aurora", "!1:"). RUN Aurora.``` command on a launchpad.
Choose a **program** and a target vessel. All of the selections are saved locally on the craft at volume 1: as well as current craft state, phase etc. so **you can leave a vessel and come back to it later, the program will start where it last left off.**
After confirming a program, vessel will get a unique ID alongside the crafts name. Upon completing the program, the crafts name will be added to the src program, so you can target it on the next rocket launch in the same program.
 
If you want to use the Journal module, make sure to have a lot of disk space on a craft.
## 4.  ~~Journal and Inspector~~ 
Not built yet, in development. 
Journal modules saves craft telemetry every 3 seconds after the launch on volume 1: and if there is a connection to KSC, also in  0: flightlogs.
Inspector is an electron app to open the and analyze flight-logs telemetry.
![inspector screenshot](https://i.imgur.com/uyRieuv.jpg)
## 5. Modules

- PreLaunch - shows current phase angle of targeted vessel and the target phase angle,
checks engines and sensors, starts a 5 seconds countdown on user input then fires the engines,
- TakeOff - releases launch clamps, sets PIDs and other variables for the other modules
 - CheckCraftConditions - checks if monopropellant or electriccharge is below safe treshold, if so, stops timewarp, deploys panels and turns on powercells, cuts of throttle.
- HandleStaging - auto stage when resources are depleted or until there is thrust, engine cut-off for a few seconds after separation
- Thrusting - autopilot a craft to sub-orbit with specified apoapsis, using optimal trajectory based on current TWR, maximal dynamic pressure,  abort on course deviation
- Deployables - auto-deploy fairings, panels, antennas on safe altitude and when a program is completed
- Injection - orbit insertion on apoapsis to a desired orbital period
- Coasting - warp to a next maneuver (Injection)
- CorrectionBurn - using RCS precisely achieve target orbital period

## 6. Future plans
- more program configuration like ascent slope, safe distance of starting throttle and turn maneuver control
- running modules manually from a menu, switching target vessels
- support of other bodies then Kerbin
- more modules, like docking to a specific port
- automatic stage/decouplers detection, no need for staging order, check if stage has necessary resources for a maneuver
- live telemetry Inspector