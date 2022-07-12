/*************************************************/
/* Copyright 2008-2010 SAS Institute Inc.        */
/* Top N report variation - Count is the measure */
/* Use macro variables to customize the data     */
/* source.                                       */
/* DATA - SAS library.member for input data      */
/* REPORT - column to report on                  */
/* N - The "N" in Top N - how many to show       */ 
/*************************************************/
%let data=SASHELP.CARS;
%let report=MAKE;
%let n=10;

data work._tpnview / view=work._tpnview; 
  set &data; 
  _tpncount=1; 
  label _tpncount='Count'; 
run; 
title "Automakers with the most Models";
footnote;

/* do not change these for the Count report */
%let data=work._tpnview; 
%let measure=_tpncount;
%let stat=SUM;
%let measureformat=;

/* summarize the data and store */
/* the output in an output data set */
proc means data=&data &stat noprint;
	var &measure;
	class &report;
	output out=summary &stat=&measure /levels;
run;

/* store the value of the measure for ALL rows and 
/* the row count into a macro variable for use  */
/* later in the report */
proc sql noprint;
select &measure,_FREQ_ into :overall,:numobs
from summary where _TYPE_=0;
quit;

/* sort the results so that we get the TOP values */
/* rising to the top of the data set */
proc sort data=work.summary out=work.topn;
  where _type_>0;
  by descending &measure;
run;

/* Pass through the data and output the first N */
/* values  */
data topn;
  length rank 8;
  label rank="Rank";
  set topn;
  by descending &measure;
  rank+1;
  if rank le &n then output;
run;

/* Create a report listing for the top values */
footnote2 "&report: Counted &overall values (&numobs total rows)";
proc report data=topn;
	column rank &report &measure;
	define rank /display;
	define &measure / analysis &measureformat;	
run;
quit; 

/* Create a simple bar graph for the data to show the rankings */
/* and relative values */
goptions xpixels=600 ypixels=400;
proc gchart data=topn
;
	hbar &report / 
		sumvar=&measure
		descending
		nozero
		clipref
		frame	
		discrete
		type=&stat
;
run;
quit;
