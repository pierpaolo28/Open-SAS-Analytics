%let file /home/u45270602/programming1/data;

proc import datafile="&file/np_traffic.csv" dbms=csv  out=traffic replace;
	guessingrows=max;
run;

proc contents data=traffic;
run;