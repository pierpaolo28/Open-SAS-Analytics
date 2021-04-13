proc transpose data=pg2.np_2016camping out=work.camping2016_t(drop=_name_);
	var campcount;
	id camptype;
	by parkname;
run;