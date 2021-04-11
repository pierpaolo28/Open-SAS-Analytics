%let cat=BIRD;

proc print data=pg1.np_species(obs=10);
run;

data mammal;
	set pg1.np_species;
	where upcase(category)="&cat";
	drop abundance seasonality conservation_status;
run;

proc freq data=mammal;
	table record_status;
run;