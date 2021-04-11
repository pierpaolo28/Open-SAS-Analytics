proc print data=pg1.eu_occ(obs=10);
run;

data eu_occ_total;
	set pg1.eu_occ;
	year = substr(yearmon, 1, 4);
	month = substr(yearmon, 6, 2);
	reportdate = mdy(month, 1, year);
	total = sum(of hotel--camp);
	format hotel shortstay camp total comma17.;
	format reportdate monyy7.;
	keep country hotel shortstay camp reportdate total;
run;