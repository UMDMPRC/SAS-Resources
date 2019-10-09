
%macro dummy2(list);
/*the let statement defines a new macro variable*/  
/*sysfunc is an internal sas macro function that with this option allows us to count words in the list we want to run through*/
%let count=%sysfunc(countw(&list.));
/*now we start a loop, in macros loop statements need to be preceeded by the percent signs*/
%do i=1 %to &count;
/*scan is another internal sas function that looks within an object and will identify the number*/
	%let var=%scan(&list,&i);
	/*define a variable set to 0*/
	&var.=0;
	/*recode the defined variable to be 1 if origin takes on the value in the list*/
 	 if origin="&var." then &var.=1;
	 /*end terminates the loop*/
 %end;
 /*mend closes out the macro*/
%mend dummy2;
