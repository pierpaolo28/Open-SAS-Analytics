/*
Write a SAS program that will:
	• Read sashelp.shoes as input.
	• Create the SAS data set work.sortedshoes.
	• Sort the sashelp.shoes data set:
		o First by variable product in descending order.
		o Second by variable sales in ascending order.
*/

proc sort data=sashelp.shoes out=work.sortedshoes;
	by descending product sales;
run;