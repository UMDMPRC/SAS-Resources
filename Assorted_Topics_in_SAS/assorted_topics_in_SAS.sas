/*SQL is a more general language for working with databases*/
/*It allows much of the same functionality as base SAS but with a lot of nice features for 
complex merges and data manipulation*/

/*the basics of a data load in, SAS vs SQL*/
	data baseball;
    set sashelp.baseball;
    run;
/*Same as SQL commands like this*/
    proc sql;
    create table baseballsql as /*Make new data set*/
    select * /*Keep all variables*/
    from sashelp.baseball; /*The set statement piece*/
    quit;
/*Data manipulation in base SAS, developing a count per group measure in base SAS*/
proc sort data=baseball;
by team;
run;
data baseball2; set baseball;
by team;
  if first.team then do;
    hitspteam=nhits;
    count_identifier=1;
  end;
  else do;
    hitspteam+nhits;
    count_identifier+1;
  end;
  if last.team then output;
run;

proc print data=baseball2;
var hitspteam count_identifier;
run;

/*Now let's see how we could do the same thing in SQL*/
proc sql;
create table baseballsql as 
select * /*keep all variables*/, 
sum(nhits) as hitspteam, /*Sums number of hits*/
count(team) as count_identifier /*Counts number on team*/
from sashelp.baseball 
group by team; 
/*Indicates that transformations on team level*/
quit;


/*SQl also is my preferred way of subsetting sas data via a where statement, here's an example*/
proc sql;
create table check as
select *
from sashelp.baseball
where nhits>40;
quit;

proc sql;
create table merged as
/*Select can be used to specify subsets
from different data sources */
select a.*, b.hitspteam 
from sashelp.baseball as a, baseballsql as b
where a.team=b.team and nhits<100;
quit;
/*SQL supports complex merges, here is one example*/
proc sql;
create table merged2 as
select *
from sashelp.baseball a
inner join baseballsql b
on a.team=b.team;
quit;

/*Let's switch gears and talk about a new data set and macros*/

/*macros can be variables or functions, they can be used for reducing coding burden and simplifying
tasks that would otherwise need to be done multiple times.*/

data cars;
set sashelp.cars;
Asia=1;
if origin="Asia" then Asia=2;
Europe=1;
if origin="Europe" then Europe=2;
USA=1;
if origin="USA" then USA=2;
run;
/*mprint gives the assessment of the macro*/
options mprint;

/*this will be a simple macro for recoding a series of variables*/
/* %macro says we are going to start a macro, the next object is the macro name and within
parantheses are any objects that will be locally called in the macro*/
%macro dummy(list);
/*the let statement defines a new macro variable*/  
/*sysfunc is an internal sas macro function that with this option allows us to count words in the list we want to run through*/
%let count=%sysfunc(countw(&list.));
/*now we start a loop, in macros loop statements need to be preceeded by the percent signs*/
%do i=1 %to &count;
/*scan is another internal sas function that looks within an object and will identify the number*/
	%let var=%scan(&list,&i);
	/*recode each variable in the list*/
 	 if &var=2 then &var=0;
	 /*end terminates the loop*/
 %end;
 /*mend closes out the macro*/
%mend dummy;
/*again let defines the macro*/
%let mylist=Asia Europe USA;
/*put displays the contents of the macro*/
%put &mylist;

data cars2;
set cars;
%dummy(&mylist.);
run;


/*We can combine macros with SQl, here's an example that takes things one step further*/

proc sql; 
select distinct origin into :orig separated by " "
from sashelp.cars;
quit;

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

data cars3;
set sashelp.cars;
%dummy2(&orig.);
run;

proc freq data=cars3;
table Asia Europe USA origin;
run;

/*SAS has some internal macro variables that can come in handy, one of my favorite is sysdate*/

%put &sysdate.;
run;


/*Macro variables can be accessed outside of macro functions, here's another example. Say you are worried about version control on a project
and want to be able to track each version of a data set that's created. we can use sysdate here;*/

data cars&sysdate.;
set sashelp.cars;
run;

/*macro statements can also be used to call in other sas files and make them available for use*/
/*Say you have a set of locations you plan to use regularly*/

%include "C:\Users\heidej\Documents\Assorted_Topics_in_SAS\libnames.sas";
