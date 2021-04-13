proc print data=pg2.np_2016camping(obs=10);
run;

proc sort data=pg2.np_2016camping(keep=camptype) out=uniquecamptypes nodupkey;
	by _all_;
run;

proc freq data=pg2.np_2016camping;
	table camptype;
run;

proc sort data=pg2.np_2016camping;
	by parkname;
run;

data campingwide;
	set pg2.np_2016camping;
	retain tent rv backcountry;
	if camptype='Tent' then tent=campcount;
	else if camptype='RV' then rv=campcount;
	else if camptype='Backcountry' then backcountry=campcount;
	by parkname;
	if last.parkname;
	keep parkname tent rv backcountry;
	format tent rv backcountry comma15.;
run;
	