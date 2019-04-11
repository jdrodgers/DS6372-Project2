title 'Logistic Regression for Advertising';
PROC IMPORT OUT= WORK.advertising
            DATAFILE= "/home/daveknockwin0/advertising-categorized-timestamp.csv"
            DBMS=CSV REPLACE;
     GETNAMES=YES;
     DATAROW=2;
RUN;
DATA advertising2;
SET advertising;
    id = _N_;
RUN;
proc print data=advertising2; run;



PROC LOGISTIC DATA = advertising2 DESCENDING;
CLASS AMPM SixHourGroup SixHourGroupAlternative FourHourGroup FourHourGroupAlternative EightHourGroup EightHourGroupAlternative;
MODEL ClickedOnAd = DailyTimeSpentOnSite Age AreaIncome DailyInternetUsage Male Month Day Year Hour Minute AMPM SixHourGroup SixHourGroupAlternative FourHourGroup FourHourGroupAlternative EightHourGroup EightHourGroupAlternative / LACKFIT CTABLE;
TITLE 'Advertising Data';
RUN;



proc logistic data=advertising2;
model ClickedOnAd(event='1') = DailyTimeSpentOnSite;
run;
proc logistic data=advertising2;
model ClickedOnAd(event='1') = Age;
run;
proc logistic data=advertising2;
model ClickedOnAd(event='1') = AreaIncome;
run;
proc logistic data=advertising2;
model ClickedOnAd(event='1') = DailyInternetUsage;
run;
proc logistic data=advertising2;
model ClickedOnAd(event='1') = Minute;
run;
proc logistic data=advertising2;
class ClickedOnAd;
model ClickedOnAd(event='1')= DailyTimeSpentOnSite Age AreaIncome DailyInternetUsage Minute;
output out=advertisingLogRegOut predprobs=I p=predprob resdev=resdev reschi=pearres;
run;
proc gplot data=advertisingLogRegOut;
plot resdev*id;
plot pearres*id;
run; quit;