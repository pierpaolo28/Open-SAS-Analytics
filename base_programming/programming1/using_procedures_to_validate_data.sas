proc freq data=pg1.np_summary;
	tables reg type;
run;

proc univariate data=pg1.np_summary;
	var acres;
run;

proc print data=pg1.np_summary(obs=100);
run;