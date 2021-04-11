data np_summary2;
	set pg1.np_summary;
	parktype= scan(parkname, -1);
	keep reg type parkname parktype;
run;