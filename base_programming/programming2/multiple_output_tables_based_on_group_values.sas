proc print data=pg2.np_acres(obs=10);
run;

proc sort data=pg2.np_acres out=sortacres(keep=region parkname state grossacres);
	by region parkname;
run;

data singlestate multistate;
	set sortacres;
	by region parkname;
	format grossacres comma15.;
	if first.parkname=1 and last.parkname=1 then output singlestate;
	else output multistate;
run;
	
	
	