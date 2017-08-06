  // Global/ Aurora scopre variables 

GLOBAL LOCK q_pressure TO ROUND(SHIP:Q * CONSTANT:ATMtokPa, 3). 
GLOBAL LOCK acc_vec TO SHIP:SENSORS:ACC - SHIP:SENSORS:GRAV. 
GLOBAL ship_log TO Journal().
GLOBAL Display TO Displayer().
GLOBAL ship_state IS ShipState().