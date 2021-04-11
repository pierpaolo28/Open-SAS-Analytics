proc means data=pg1.np_westweather;
	where precip ^= 0;
	var precip;
	class name year;
	ways 2;
	output out=rainstats n=raindays sum=totalrain;
run;

title "Rain Statistics by Year and Park";
proc print data=rainstats noobs label;
	var name year raindays totalrain;
	label name="Park Name" raindays="Number of Days Raining" totalrain="Total Rain Amount (Inches)";
run;
	