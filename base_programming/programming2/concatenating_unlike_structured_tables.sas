proc print data=pg2.np_2015(obs=10);
run;

proc print data=pg2.np_2016(obs=10);
run;

proc print data=pg2.np_2014(obs=10);
run;

data work.np_combine;
	set pg2.np_2014(rename=(park=parkcode type=parktype)) pg2.np_2015 pg2.np_2016;
	camptotal = sum(of camping:);
	where month in(6, 7, 8) and parktype='National Park';
	format camptotal comma15.;
	drop camping:;
run;

proc sort data=work.np_combine;
	by parktype parkcode year month;
run;

