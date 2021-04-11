/*
This project will work with the following program:
	data work.lowchol work.highchol;
	 set sashelp.heart;
	 if cholesterol lt 200 output work.lowchol;
	 if cholesterol ge 200 output work.highchol;
	 if cholesterol is missing output work.misschol;
	run;
This program is intended to:
	• Divide the observations of sashelp.heart into three data sets, work.highchol, work.lowchol, and 
	work.misschol
	• Only observations with cholesterol below 200 should be in the work.lowchol data set. 
	• Only Observations with cholesterol that is 200 and above should be in the work.highchol data 
	set. 
	• Observations with missing cholesterol values should only be in the work.misschol data set.
Fix the errors in the above program. There may be multiple errors in the program. Errors may be syntax 
errors, program structure errors, or logic errors. In the case of logic errors, the program may not 
produce an error in the log.
*/

data work.lowchol work.highchol work.misschol;
 set sashelp.heart;
 if cholesterol = . then output work.misschol;
 else if cholesterol lt 200 then output work.lowchol;
 else output work.highchol;
run;