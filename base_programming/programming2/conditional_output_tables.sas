proc print data=pg2.np_2017(obs=10);
run;

data camping(keep=parkname month dayvisits camptotal) lodging(keep=parkname month dayvisits lodgingother);
	set pg2.np_2017;
	format camptotal comma12.;
	*camptotal=sum(of camping:);
	camptotal = sum(of campingother--campingbackcountry);
	if camptotal > 0 then output camping;
	if lodgingother > 0 then output lodging;
run;