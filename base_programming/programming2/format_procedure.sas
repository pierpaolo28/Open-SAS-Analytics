proc print data=sashelp.shoes(obs=10);
run;

proc format;
	value $clothe_type "Boot", "Sandal", "Slipper", "Sport Shoe" = "Foot"
						"Men's Casual", "Men's Dress", "Women's Casual", "Women's Dress" = "Clothes"
						other = "Unknown";
	
	value money low-100 = "Low"
				 100<-1000 = "Medium"
				 1000<-high = "High";
run;

proc freq data=sashelp.shoes;
	table product;
	format product $clothe_type.;
run;

proc freq data=sashelp.shoes;
	table returns;
	format returns money.;
run;

proc freq data=sashelp.shoes;
	tables product*returns;
	format product $clothe_type. returns money.;
run;

proc print data=sashelp.shoes(obs=10);
	format product $clothe_type. returns money.;
run;