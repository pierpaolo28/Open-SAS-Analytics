title "Weather Statistics by Year and Park";
proc means data=pg1.np_westweather mean min max maxdec=2;
	var precip snow tempmin tempmax;
	class year name;
run;