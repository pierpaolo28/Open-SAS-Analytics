%let parkcode=ZION;
%let speciescat=Bird;

proc freq data=pg1.np_species;
	where species_id like "&parkcode%" and category="&speciescat";
	tables abundance conservation_status;
run;

proc print data=pg1.np_species;
	var species_id category scientific_name common_names;
	where species_id like "&parkcode%" and category="&speciescat";
run;