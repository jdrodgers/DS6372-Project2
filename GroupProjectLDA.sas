title 'Logistic Regression for Advertising';
PROC IMPORT OUT= WORK.advertising
            DATAFILE= "D:\Code\DS6372-Project2\advertising-categorized-timestamp.csv"
            DBMS=CSV REPLACE;
     GETNAMES=YES;
     DATAROW=2;
RUN;

DATA advertising2;
SET advertising;
    id = _N_;
    if DailyInternetUsage gt 180 then aboveAvgTime = 1;
         else aboveAvgTime = 0;
RUN;
proc print data=advertising2; run;


proc surveyselect data=advertising2 out=testsplit method=srs samprate=0.80
         outall seed=12345 noprint;
  samplingunit id;
run;

data Train;
        set testsplit(where=(Selected=1));
run;

data Test;
        set testsplit(where=(Selected=0));
run;

/* Initial EDA */
/*Means and distribution of data*/
proc means data = WORK.advertising n nmiss min mean median max std;
	var DailyTimeSpentOnSite Age AreaIncome DailyInternetUsage Male Timestamp
		Month Day Year Hour Minute ClickedOnAd;
run;

/*Histograms and scatterplots*/
proc univariate data = WORK.advertising noprint;
	class ClickedOnAd;
	histogram DailyTimeSpentOnSite Age AreaIncome DailyInternetUsage Male 
		Timestamp Month Day Year Hour Minute;
run;

proc sgscatter data = WORK.advertising;
matrix DailyTimeSpentOnSite Age AreaIncome DailyInternetUsage Male 
		/ diagonal=(histogram) group=clickedonad;
run;

proc sgscatter data = WORK.advertising;
matrix Month Day Hour Minute / diagonal=(histogram) group=clickedonad;
run;

/* correlation matrix of dataset for included variables */
proc corr data=advertising2;
var Age AreaIncome DailyTimeSpentOnSite DailyInternetUsage;
run;

/* VIF */
proc reg data = WORK.advertising plots = all;
	model ClickedOnAd = Age AreaIncome DailyInternetUsage 
	DailyTimeSpentOnSite / vif;
run;


/* T-Test between DailyTimeSpentOnSite, Age, DailyInternetUsage, AreaIncome */
proc ttest data = WORK.advertising sides=2 h0=0 plots(showh0);
	class ClickedOnAd;
	var DailyTimeSpentOnSite;
run;

proc ttest data = WORK.advertising sides=2 h0=0 plots(showh0);
	class ClickedOnAd;
	var Age;
run;

proc ttest data = WORK.advertising sides=2 h0=0 plots(showh0);
	class ClickedOnAd;
	var DailyInternetUsage;
run;

proc ttest data = WORK.advertising sides=2 h0=0 plots(showh0);
	class ClickedOnAd;
	var AreaIncome;
run;

/*Runs basic logistic regression*/
proc logistic data=Train plots(only label)=(leverage dpc roc(id=obs) effect);
	model ClickedOnAd(event='1')=  Age AreaIncome DailyInternetUsage DailyTimeSpentOnSite / 
		link=logit technique=fisher LACKFIT CTABLE;
	effectplot fit/obs(jitter(y=0.02));
	score data = test out=Score1 fitstat;
run;

/*Runs logistic regression with interaction*/
proc logistic data=Train plots(only label)=(leverage dpc roc(id=obs) effect);
	model ClickedOnAd(event='1')=  Age AreaIncome DailyInternetUsage*DailyTimeSpentOnSite / 
		link=logit technique=fisher LACKFIT CTABLE;
	effectplot fit/obs(jitter(y=0.02));
	score data = test out = Score2 fitstat;
run;

/* running QDA on the test set */                                                                                                                                                                                                                     
title 'QDA';
proc discrim data = train                                                                                                                                                                                                                             
         pool = test crossvalidate 
	 testdata=test testout = lda;                                                                                                                                                                                       
class ClickedOnAd;                                                                                                                                                                                                                                    
var Age AreaIncome DailyTimeSpentOnSite DailyInternetUsage;                                                                                                                                                                                           
run;                                                                                                                                                                                                                                                  

/* running k-nearest neighbors on the test set */                                                                                                                                                                                                     
title 'kNN';
proc discrim data = train                                                                                                                                                                                                                             
         method=npar k=5 /* apply k-nn classification method using 5 nearest neighbors */
	 testdata=test testout = knn;                                                                                                                                                                                                 
class ClickedOnAd;                                                                                                                                                                                                                                    
var Age AreaIncome DailyTimeSpentOnSite DailyInternetUsage;                                                                                                                                                                                           
run;
