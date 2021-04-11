%let foxtable &outpath/fox.sas7bdat;

data "&foxtable";
	set pg1.np_species;
	where category="Mammal" and upcase(common_names) like '%FOX%' and upcase(common_names) not like '%SQUIRREL%';
	drop category record_status occurrence nativeness;
run;

proc sort data="&foxtable";
	by common_names;
run;