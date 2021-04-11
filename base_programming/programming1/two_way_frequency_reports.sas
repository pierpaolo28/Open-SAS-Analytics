title "Park Types by Region";
proc freq data=pg1.np_codelookup order=freq;
	tables type*region / nopercent;
	where upcase(type) not like '%OTHER%';
run;
title;

title "Selected Park Types by Region";
proc freq data=pg1.np_codelookup order=freq;
	tables type*region / nopercent crosslist plots=freqplot(groupby=row scale=grouppercent orient=horizontal);
	where type in ("National Historic Site", "National Monument", "National Park");
run;
title;



	