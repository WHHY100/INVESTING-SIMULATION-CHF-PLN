/*clean work*/
proc datasets lib=work kill nolist;
run;

/*
==============================================================
CHF exchange rate - download from NBP, year by year
==============================================================
*/

data tab_possible_years;
do year = 2012 to 2021;
	output;
end;
run; 

data tab_url_link;
retain id;
set tab_possible_years;
url = cats('https://www.nbp.pl/kursy/Archiwum/publ_sredni_m_', year , '.csv');
id = _N_;
run;

%macro read_chf_rate;

proc sql noprint;
select max(id) into: var_loop_maxid from tab_url_link
;quit;

%do i = 1 %to &var_loop_maxid;

	proc sql noprint;
	select year into: var_year from tab_url_link where id = &i
	;quit;
	
	proc sql noprint;
	select cats('"', url, '"') into: var_url from tab_url_link where id = &i
	;quit;
	
	filename tempFile temp;
	proc http
	url=&var_url
	method="get" out=tempFile;
	run;
	
	proc import 
	datafile=tempFile
	out=tab_currency_rate replace
	dbms=dlm;
	delimiter=';';
	getnames=no;
	run;
	
	data tab_currency_tmp_CHF_1;
	set tab_currency_rate;
	where VAR2 = 'CHF';
	rename VAR2 = CURR;
	keep VAR2 VAR4 VAR5 VAR6 VAR7 VAR8 VAR9 VAR10 VAR11 VAR12 VAR13 VAR14 VAR15;
	run;
	
	proc transpose data=tab_currency_tmp_CHF_1 out=tab_currency_tmp_CHF_2;
	by CURR;
	var VAR4 VAR5 VAR6 VAR7 VAR8 VAR9 VAR10 VAR11 VAR12 VAR13 VAR14 VAR15;
	run;
	
	data tab_currency_tmp_CHF_3;
	retain year month;
	set tab_currency_tmp_CHF_2;
	month = _N_;
	year = &var_year;
	CURR_RATE = input(tranwrd(COL1, ',', '.'), best12.);
	drop _NAME_ COL1;
	run;
	
	%if &i = 1 %then %do;
		data tab_rate_CHF;
		set tab_currency_tmp_CHF_3;
		run;
	%end;
	%else %do;
		data tab_rate_CHF;
		set tab_rate_CHF tab_currency_tmp_CHF_3;
		run;
	%end;
	
	proc delete data=tab_currency_tmp_CHF_1;
	proc delete data=tab_currency_tmp_CHF_2;
	proc delete data=tab_currency_tmp_CHF_3;

%end;
%mend;

%read_chf_rate;

/*
==============================================================
simulation assumptions:
-save 500 PLN to deposit (5%, monthly capitalization, tax 19%)
-change 500PLN to CHF (no interest on the deposit)
-start 2012.01, end 2021.12
==============================================================
*/

data tab_deposit_PLN;
set tab_rate_CHF;
interest = 0.035;
tax = 0.19;
amount_PLN = 500;
save_amount_monthly_PLN = 500;
do i = 2 to _N_;
	amount_PLN = round(amount_PLN + ((amount_PLN * interest)/12 - ((amount_PLN * interest)/12*tax))+save_amount_monthly_PLN, .01);
end;
keep year month interest tax save_amount_monthly_PLN amount_PLN;
run;

data tab_exch_CHF_tmp;
retain id;
set tab_rate_CHF;
save_amount_monthly_PLN = 500;
amount_CHF_tmp = save_amount_monthly_PLN/CURR_RATE;
id = _N_;
keep id year month save_amount_monthly_PLN CURR_RATE amount_CHF_tmp;
run;

%macro create_exch_CHF;

proc sql noprint;
select max(id) into: var_exch_max_id from tab_exch_CHF_tmp
;quit;

%do i = 1 %to &var_exch_max_id;
	proc sql;
	create table tab_exch_CHF_tmp_1 as
	select
		&i as id
		,round(sum(amount_CHF_tmp), .01) as amount_CHF
	from tab_exch_CHF_tmp
	where id <= &i
	;quit;
	
	%if &i = 1 %then %do;
		data tab_exch_CHF_1;
		set tab_exch_CHF_tmp_1;
		run;
	%end;
	%else %do;
		data tab_exch_CHF_1;
		set tab_exch_CHF_1 tab_exch_CHF_tmp_1;
		run;	
	%end;
%end;
%mend;

%create_exch_CHF;

proc sql;
create table tab_exch_CHF as
select
	a.year
	,a.month
	,a.save_amount_monthly_PLN
	,a.CURR_RATE
	,b.amount_CHF
	,round(b.amount_CHF * a.CURR_RATE) as amount_PLN
from tab_exch_CHF_tmp a
left join tab_exch_CHF_1 b on a.id = b.id
;quit;

/*
==============================================================
summary simulation
==============================================================
*/
proc sql;
create table tab_simulation as
select
	a.year
	,a.month
	,a.interest
	,a.tax	
	,a.amount_PLN as amount_PLN_dep_interest
	,amount_CHF
	,b.CURR_RATE as CHF_exch_rate
	,b.amount_PLN as amount_PLN_dep_CHF_nointerest
from tab_deposit_PLN a
left join tab_exch_CHF b on a.year = b.year and a.month = b.month
order by a.year, a.month
;quit;

/*
==============================================================
export results
==============================================================
*/

%let path_export = /home/u45585517/sasuser.v94/INWESTYCJE/RESULT;

/*full report pdf*/
ods pdf file="&path_export/FULL_REPORT.pdf";
proc print data=work.tab_simulation;
title color="#00008B" "Period savings report";
run;
ods pdf close;

proc sql noprint;
select max(year) into: var_last_year from tab_simulation
;quit;

title color="#00008B" "Period savings report (last year)";
ods graphics on / imagefmt=jpg imagemap=on imagename="LAST_YEAR" border=off;
options printerpath=png nodate nonumber;
ods printer file="&path_export/LAST_YEAR.jpg" style=barrettsblue;
proc print noobs data=tab_simulation(where=(year=&var_last_year));
run;
ods printer close;
