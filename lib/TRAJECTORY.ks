function calcTrajectory{
	LOCAL PARAMETER alt.
	DECLARE LOCAL funcx TO ROUND(1-((alt^2)/(70000^2))^0.25,3).
	RETURN ROUND((SIN(funcx*CONSTANT:RadToDeg))*(90*1.1884),2).
}