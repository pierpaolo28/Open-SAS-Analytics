/*
Write a SAS program that will:
	• Read sashelp.shoes as input.
	• Create a new SAS data set, work.shoerange.
	• Create a new character variable SalesRange that will be used to categorize the observations into 
	three groups.
	• Set the value of SalesRange to the following:
		o Lower when Sales are less than $100,000.
		o Middle when Sales are between $100,000 and $200,000, inclusively.
		o Upper when Sales are above $200,000.
*/

data work.shoerange;
	set sashelp.shoes;
	length salesrange $ 10;
	if sales < 100000 then salesrange='Lower';
	else if 100000 <= sales <= 200000 then salesrange='Middle';
	else salesrange='Upper';
run;

proc freq data=work.shoerange;
	tables salesrange;
run;

proc means data=work.shoerange maxdec=0;
	var sales;
	where salesrange='Middle';
run;