proc print data=sashelp.shoes(obs=10);
run;

proc sort data=sashelp.shoes out=sortshoes;
	by region product;
run;

data profitsummary;
	set sortshoes;
	by region product;
	profit=sales-returns;
	if first.region=1 or first.product=1 then totalprofit=0;
	totalprofit+profit;
run;

data profitsummary2;
	set sortshoes;
	by region product;
	profit=sales-returns;
	format totalprofit dollar12.;
	if first.region=1 or first.product=1 then totalprofit=0;
	totalprofit+profit;
	if last.product=1 then output profitsummary2;
	keep region product totalprofit;
run;

