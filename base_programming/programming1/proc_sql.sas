proc contents data=sashelp.shoes;
run;

proc sql;
select region, product, sales from sashelp.shoes where sales>100000 and product='Slipper' order by sales desc;
quit;