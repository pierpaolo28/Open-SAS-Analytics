proc print data=pg2.np_monthlytraffic(obs=10);
run;

data cuyahoga_maxtraffic;
	set pg2.np_monthlytraffic;
	where parkname = 'Cuyahoga Valley NP';
	retain trafficmax 0 monthmax locationmax;
	format count trafficmax comma15.;
	if count > trafficmax then do;
		trafficmax=count;
		monthmax=month;
		locationmax=location;
	end;
	keep location month count trafficmax monthmax locationmax;
run;