proc print data=pg2.np_codelookup(obs=10);
run;

proc print data=pg2.np_2016(obs=10);
run;

proc sort data=pg2.np_codelookup out=sortcode;
	by parkcode;
run;

proc sort data=pg2.np_2016 out=datasort;
	by parkcode;
run;

data work.parkstats(keep= parkcode parkname year month dayvisits) work.parkother(keep= parkcode parkname);
	merge sortcode datasort(in=data);
	by parkcode;
	if data=1 then output work.parkstats;
	else output work.parkother;
run;