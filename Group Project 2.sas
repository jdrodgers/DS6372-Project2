title 'Logistic Regression for Advertising';
PROC IMPORT OUT= WORK.advertising
            DATAFILE= "/home/daveknockwin0/advertising.csv"
            DBMS=CSV REPLACE;
     GETNAMES=YES;
     DATAROW=2;
RUN;
proc print data=advertising; run;



PROC LOGISTIC DATA = advertising DESCENDING;
CLASS Gender Country;
MODEL ClickedOnAd = DailyTimeSpentOnSite Age AreaIncome DailyInternetUsage Gender Country / LACKFIT CTABLE;
TITLE 'Advertising Data';
RUN;