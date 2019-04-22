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

data train;
        set testsplit(where=(Selected=1));
run;

data test;
        set testsplit(where=(Selected=0));
run;

proc corr data=advertising2;
var Age AreaIncome DailyTimeSpentOnSite DailyInternetUsage;
run;

proc discrim data = train                                                                                                                                                                                                                             
         pool = test crossvalidate testdata=test testout = lda;                                                                                                                                                                                       
class ClickedOnAd;                                                                                                                                                                                                                                    
var Age AreaIncome DailyTimeSpentOnSite DailyInternetUsage;                                                                                                                                                                                           
run;                                                                                                                                                                                                                                                  
                                                                                                                                                                                                                                                      
proc discrim data = train                                                                                                                                                                                                                             
         method=npar k=5 testdata=test testout = knn;                                                                                                                                                                                                 
class ClickedOnAd;                                                                                                                                                                                                                                    
var Age AreaIncome DailyTimeSpentOnSite DailyInternetUsage;                                                                                                                                                                                           
run;                                                                                                                                                                                                                                                  
    


