
/*typically at the start of my sas files I start by defining a location to be referenced for this class,
I'm going to name a library called my stuff placed in this location on my computer*/
libname mystuff "C:\Users\heidej\Documents\Intro_to_SAS";


/*We are going to start by reading in a sas data set.  The general structure for loading in a data set in SAS is:
Line 1. data line (data you want to create);
Line 2. data being read from.;
Line 3 run statement; -- this is sas's cue to run the code.  Note sas statements end with a ';'  This differs from stata defaults
*/
data test;
/*Also note, sas comes with a series of preloaded datasets, these are all within the sashelp location*/
set sashelp.baseball;
run;

/*Let's look at what is in this dataset, the proc content gives us a high level overview*/
proc contents data=test;
run;

/*Proc print provides another way of showing the data*/
proc print data=test;
run;
/*For large datasets we may want to control the number of observations shown and the number of variables*/
proc print data=test (obs=10);
/*the variable option also allows us to subset the data to look at particular variables*/
var Name Salary;
run;
/*Now let's make some modifications to this data set*/
/*In the data and set statements, we can control what variables */
data test2 (drop=nhits);
set test;
dummy=1;
/*This is a simple conditional logical statement, if hits =31 then this dummy variable is set to missing*/
/*Note SAS has many ways of defining missing data, but they all start with the . symbol*/
if nhits=31 then dummy=.;
nHitsdup=nhits;
homerunratio=nHome/nHits;
homerunmult=nHome*nHits;
newplayer=0;
if YrMajor=1 then newplayer=1;

/*This is another example of conditional logic, note these next four lines of code produce the same result
in SAS  < is the same as LT, <= is the same as LE, GT is the same as > GE is the same as >= */

/*in SAS "and" and "or" can be used to define multiple conditons*/
lowsalary=0;
if salary>=0 and salary<=100 then lowsalary=1;
lowsalary2=0;
if salary>=0 and salary<=100 then lowsalary2=1;

run;
/*if we want to see modifications to the data set, we can use a proc compare command*/
proc compare base=test2 compare=test;
run;

/*All of the work so far has been in a remote session, if we wanted to save a physical copy of the data set
we could do this by adding a library location to the data step*/
data mystuff.test2;
set test2;
run;

/*If we want to load a data set, we could do pretty much the same thing but in reverse*/

data test3;
set mystuff.test2;
run;


/*Now let's move to some basic data analysis;

/*to make a table*/

proc freq data=test2;
table newplayer;
run;

/*and a cross table*/

proc freq data=test2;
table nhitsdup;
by newplayer;
run;

/*this won't work because data needs to be sorted in order of the by variable.  here's how to do that*/

proc sort data=test2;
by newplayer;
run;

/*now the code works*/
proc freq data=test2;
table nhitsdup;
by newplayer;
run;


/*we can also export these results into a separate sas data set*/
proc freq data=test2 ;
table nhitsdup /out=results;
by newplayer ;
run;

proc print data=results;
run;


/*by default sas excludes missing values, specifying the missing value can show them*/

proc freq data=test2;
table dummy/ missing out=results2;
run;
/*there are other summary commands we can use*/
proc univariate data=test2;
var nhitsdup homerunratio newplayer;
run;

/*another favorite of mine is proc means*/

/*proc means can also be used to generate output but the structure is a bit different*/
proc means data=test2;
var nhitsdup;
output out=results3;
run;
proc means data=test2;
var nhitsdup;
class newplayer;
output out=results3;
run;

/*statistics produced by proc means can also be customized in the first line of the statement*/
proc means data=test2 p25 p50 p75 mean;
var nhitsdup;
output out=results3;
run;

/*now let's move to a multivariate context, here's a simple regression environment*/
proc reg data=test2 outest=est plots=none;
model nhitsdup=newplayer;
run;

/*the proc reg command is actually fairly limited in it's functionality, a much more flexible command is proc genmod*/
proc genmod data=test2;
/*here we specify that the variable team is to be treated as a categorical variable*/
class team;
model nhitsdup=newplayer team;
output out=pout;
run;


/*now this is an example with a logistic regression model*/
proc genmod data=test2;
class team;
model newplayer=nhitsdup team / dist = bin
                           link = logit;
output out=pout p=phat;
run;

/*export the results*/
proc export data=pout filename="regressionresults.csv" replace;
run;
