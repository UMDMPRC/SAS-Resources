
/*SAS is not case sensitive; however other statistical packages (STATA and R) are.  If you have a need 
to convert SAS variable names to be exclusively lower case, this macro will accomplish the task*/

%macro lowcase(dsn); 
     %let dsid=%sysfunc(open(&dsn)); 
     %let num=%sysfunc(attrn(&dsid,nvars)); 
     %put &num;
     data &dsn; 
           set &dsn(rename=( 
        %do i = 1 %to &num; 
        %let var&i=%sysfunc(varname(&dsid,&i));      /*function of varname returns the name of a SAS data set variable*/
        &&var&i=%sysfunc(lowcase(&&var&i))         /*rename all variables*/ 
        %end;)); 
        %let close=%sysfunc(close(&dsid)); 
  run; 
%mend lowcase; 

/*Macro applied to a test example*/

data test;
    input Id a b C $;
    datalines;
1 26 31 A
1 28 28 B
1 30 31 C
2 32 31 D
2 34 29 E
;

proc print data=test;
run;

%lowcase(test) 
proc print data=test; 
run; 
