proc sort data=pg1.eu_occ(keep= geo country) out=countrylist nodupkey;
	by geo country;
run;