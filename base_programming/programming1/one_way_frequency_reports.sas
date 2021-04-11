ods graphics on;
ods noproctitle;
title "Categories of Reported Species";
title2 "in the Everglades";
proc freq data=pg1.np_species order=freq;
	tables category / nocum plots=freqplot;
	where species_id like "EVER%" and category ^= "Vascular Plant";
run;
title