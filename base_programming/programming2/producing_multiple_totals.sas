proc print data=pg2.np_yearlytraffic(obs=10);
run;

data parktypetraffic;
	set pg2.np_yearlytraffic;
	format monumenttraffic parktraffic comma15.;
	where parktype in ('National Monument', 'National Park');
	if parktype='National Monument' then monumenttraffic+count;
	else parktraffic+count;
run;

title "Accomulating Traffic Totals for Park Types";
proc print data=parktypetraffic;
	var parktype parkname location count monumenttraffic parktraffic;
run;
title;