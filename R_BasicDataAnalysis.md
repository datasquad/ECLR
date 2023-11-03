---
title: "Basic Data Analysis"
author: "Ralf Becker"
date: "2023-11-03"
output: 
  html_document: 
    toc: true
    keep_md: yes
---



## Introduction

Let's start by loading a datafile. We are using the datafile with 752 women's wages and working hours as well as other variables. These are the data in the `mroz.csv` file ([mroz.csv](https://github.com/datasquad/ECLR/blob/gh-pages/data/Mroz.csv)). Make sure that this file is loaded into a data subfolder of your working directory. 


```r
mydata <- read.csv("data/mroz.csv",na.strings = ".")  # Opens mroz.csv from working directory
```

You may wonder what the option `na.strings = "."` does. It tells R that any `.` entry in the spreadsheet is actually a misisng observation. It is then labelled as such by R. 

Let's check out what variables we have in this data-file


```r
names(mydata)
```

```
##  [1] "inlf"     "hours"    "kidslt6"  "kidsge6"  "age"      "educ"    
##  [7] "wage"     "repwage"  "hushrs"   "husage"   "huseduc"  "huswage" 
## [13] "faminc"   "mtr"      "motheduc" "fatheduc" "unem"     "city"    
## [19] "exper"    "nwifeinc" "lwage"    "expersq"
```

The variable `hours` indicates the number of hours worked by an individual and the variable `wage` represents the estimated hourly wage earned (in 1975). You can find short variable descriptions from a link in the Datasets page (see above). You need to understand what data types the variables represent (check `str(mydata)` to confirm the R datatypes.) Common variable types are `int` for nteger numbers, `num` for any numerical variables, `chr` for text variables and `factor` for categorical variables.


```r
str(mydata)
```

```
## 'data.frame':	753 obs. of  22 variables:
##  $ inlf    : int  1 1 1 1 1 1 1 1 1 1 ...
##  $ hours   : int  1610 1656 1980 456 1568 2032 1440 1020 1458 1600 ...
##  $ kidslt6 : int  1 0 1 0 1 0 0 0 0 0 ...
##  $ kidsge6 : int  0 2 3 3 2 0 2 0 2 2 ...
##  $ age     : int  32 30 35 34 31 54 37 54 48 39 ...
##  $ educ    : int  12 12 12 12 14 12 16 12 12 12 ...
##  $ wage    : num  3.35 1.39 4.55 1.1 4.59 ...
##  $ repwage : num  2.65 2.65 4.04 3.25 3.6 4.7 5.95 9.98 0 4.15 ...
##  $ hushrs  : int  2708 2310 3072 1920 2000 1040 2670 4120 1995 2100 ...
##  $ husage  : int  34 30 40 53 32 57 37 53 52 43 ...
##  $ huseduc : int  12 9 12 10 12 11 12 8 4 12 ...
##  $ huswage : num  4.03 8.44 3.58 3.54 10 ...
##  $ faminc  : int  16310 21800 21040 7300 27300 19495 21152 18900 20405 20425 ...
##  $ mtr     : num  0.722 0.661 0.692 0.781 0.622 ...
##  $ motheduc: int  12 7 12 7 12 14 14 3 7 7 ...
##  $ fatheduc: int  7 7 7 7 14 7 7 3 7 7 ...
##  $ unem    : num  5 11 5 5 9.5 7.5 5 5 3 5 ...
##  $ city    : int  0 1 0 0 1 1 0 0 0 0 ...
##  $ exper   : int  14 5 15 6 7 33 11 35 24 21 ...
##  $ nwifeinc: num  10.9 19.5 12 6.8 20.1 ...
##  $ lwage   : num  1.2102 0.3285 1.5141 0.0921 1.5243 ...
##  $ expersq : int  196 25 225 36 49 1089 121 1225 576 441 ...
```

You can see that all data are coded as numerical or integer variables. Which datatype a variable has is important. For instance, if you want ot make any calculations with a variable (e.g. add it to something, calculate a logarithm, etc.), then this will only work if R has recognised a variable as a number (`num` or `int`). If a variable was a text (`chr`) variable, you would be nable to use it in calculations.

> When you import data, R automatically recognise the datatypes. We will see below how you can change data-types. Go back to where you importaed the data (the `read.csv` command line). Re-run this command without the option that told R what missing data are (`na.strings = "."`). Check what datatype the `wage` variable has. Can you calculate with that variable? 

## Data Summaries

One of the things you would usually like to do at the beginning of your work is to get some summary statistics for all variables in the dataset.


```r
summary(mydata)
```

```
##       inlf            hours           kidslt6          kidsge6     
##  Min.   :0.0000   Min.   :   0.0   Min.   :0.0000   Min.   :0.000  
##  1st Qu.:0.0000   1st Qu.:   0.0   1st Qu.:0.0000   1st Qu.:0.000  
##  Median :1.0000   Median : 288.0   Median :0.0000   Median :1.000  
##  Mean   :0.5684   Mean   : 740.6   Mean   :0.2377   Mean   :1.353  
##  3rd Qu.:1.0000   3rd Qu.:1516.0   3rd Qu.:0.0000   3rd Qu.:2.000  
##  Max.   :1.0000   Max.   :4950.0   Max.   :3.0000   Max.   :8.000  
##                                                                    
##       age             educ            wage            repwage    
##  Min.   :30.00   Min.   : 5.00   Min.   : 0.1282   Min.   :0.00  
##  1st Qu.:36.00   1st Qu.:12.00   1st Qu.: 2.2626   1st Qu.:0.00  
##  Median :43.00   Median :12.00   Median : 3.4819   Median :0.00  
##  Mean   :42.54   Mean   :12.29   Mean   : 4.1777   Mean   :1.85  
##  3rd Qu.:49.00   3rd Qu.:13.00   3rd Qu.: 4.9708   3rd Qu.:3.58  
##  Max.   :60.00   Max.   :17.00   Max.   :25.0000   Max.   :9.98  
##                                  NA's   :325                     
##      hushrs         husage         huseduc         huswage       
##  Min.   : 175   Min.   :30.00   Min.   : 3.00   Min.   : 0.4121  
##  1st Qu.:1928   1st Qu.:38.00   1st Qu.:11.00   1st Qu.: 4.7883  
##  Median :2164   Median :46.00   Median :12.00   Median : 6.9758  
##  Mean   :2267   Mean   :45.12   Mean   :12.49   Mean   : 7.4822  
##  3rd Qu.:2553   3rd Qu.:52.00   3rd Qu.:15.00   3rd Qu.: 9.1667  
##  Max.   :5010   Max.   :60.00   Max.   :17.00   Max.   :40.5090  
##                                                                  
##      faminc           mtr            motheduc         fatheduc     
##  Min.   : 1500   Min.   :0.4415   Min.   : 0.000   Min.   : 0.000  
##  1st Qu.:15428   1st Qu.:0.6215   1st Qu.: 7.000   1st Qu.: 7.000  
##  Median :20880   Median :0.6915   Median :10.000   Median : 7.000  
##  Mean   :23081   Mean   :0.6789   Mean   : 9.251   Mean   : 8.809  
##  3rd Qu.:28200   3rd Qu.:0.7215   3rd Qu.:12.000   3rd Qu.:12.000  
##  Max.   :96000   Max.   :0.9415   Max.   :17.000   Max.   :17.000  
##                                                                    
##       unem             city            exper          nwifeinc       
##  Min.   : 3.000   Min.   :0.0000   Min.   : 0.00   Min.   :-0.02906  
##  1st Qu.: 7.500   1st Qu.:0.0000   1st Qu.: 4.00   1st Qu.:13.02504  
##  Median : 7.500   Median :1.0000   Median : 9.00   Median :17.70000  
##  Mean   : 8.624   Mean   :0.6428   Mean   :10.63   Mean   :20.12896  
##  3rd Qu.:11.000   3rd Qu.:1.0000   3rd Qu.:15.00   3rd Qu.:24.46600  
##  Max.   :14.000   Max.   :1.0000   Max.   :45.00   Max.   :96.00000  
##                                                                      
##      lwage            expersq    
##  Min.   :-2.0542   Min.   :   0  
##  1st Qu.: 0.8165   1st Qu.:  16  
##  Median : 1.2476   Median :  81  
##  Mean   : 1.1902   Mean   : 178  
##  3rd Qu.: 1.6036   3rd Qu.: 225  
##  Max.   : 3.2189   Max.   :2025  
##  NA's   :325
```

> Look at the summary statistics. How many missing values are there in the `wage` variable?

## Dealing with missing observations

When you have missing observations in a variable, this can complicate some of the operations. Let's demonstrate this by calculating the mean `wage` value. You can do this in R by using the `mean` function.


```r
mean(mydata$wage)
```

```
## [1] NA
```

As you can see, you get the value `NA`. The reason for this is that R has detected missing values in the `wage` variable. You may ask why R is not just ignoring missing observations. There is a good reason for this. If there are missing values, you as the data analyst should carefully think why there are missing values. 

We could create a temporary subset of the data with only those observations which have missing data in the `wage` variable


```r
temp <- mydata[is.na(mydata$wage),]
```

> What do all the observations in `temp` have in common? Look at the `hours` variable.

If you decided that it was ok to ignore the missing observations in your calculation, then you could tell R to ignore the missing observations by adding the `na.rm = TRUE` option to the mean function.


```r
mean(mydata$wage,na.rm = TRUE)
```

```
## [1] 4.177682
```

> Try a few other summary statistics like the standard deviation (`sd()`), the variance (`var()`), the median (`median()`), the inter-quartile range (`IQR()`), the minimum (`min()`) or the maximum (`max()`). Also try to figure out how to calculate a percentile (say the 15th percentile) in R. You may have to internet search ("How to calculate a percentile in R") to find out. Searching the internet is one of the most important programming techniques!

A similar issue arises when you are calculating a summary statistics which involves more than one variable. Say you wanted to calculate correlations between the `educ`, `wage` and the `huswage` variables. Look at the difference in results for the following two commands.


```r
cor(mydata[c("educ","wage","huswage")])
```

```
##              educ wage   huswage
## educ    1.0000000   NA 0.2849361
## wage           NA    1        NA
## huswage 0.2849361   NA 1.0000000
```

```r
cor(mydata[c("educ","wage","huswage")],use = "complete")
```

```
##              educ      wage   huswage
## educ    1.0000000 0.3419544 0.3030052
## wage    0.3419544 1.0000000 0.2158857
## huswage 0.3030052 0.2158857 1.0000000
```

```r
cor(mydata[c("educ","wage","huswage")],use = "pairwise")
```

```
##              educ      wage   huswage
## educ    1.0000000 0.3419544 0.2849361
## wage    0.3419544 1.0000000 0.2158857
## huswage 0.2849361 0.2158857 1.0000000
```

Use the information in the help function (type `?cor` in the Console) to figure out why the results are different.

## Summary stats for selected variables

You already learned how to get summary statistics for all variables in the dataset above. Especially when you have many variables, the output of `summary(mydata)` will be quite cumbersome. You therefore often want to calculate certain summary statistics for some variables only. 

### Option 1

```r
summary(mydata[c("hours","husage")])
```

```
##      hours            husage     
##  Min.   :   0.0   Min.   :30.00  
##  1st Qu.:   0.0   1st Qu.:38.00  
##  Median : 288.0   Median :46.00  
##  Mean   : 740.6   Mean   :45.12  
##  3rd Qu.:1516.0   3rd Qu.:52.00  
##  Max.   :4950.0   Max.   :60.00
```

```r
cor(mydata[c("hours","husage")])
```

```
##              hours      husage
## hours   1.00000000 -0.03108875
## husage -0.03108875  1.00000000
```

### Option 2

```r
mydata.sub0 <- subset(mydata,select=c("hours","husage"))
summary(mydata.sub0)
```

```
##      hours            husage     
##  Min.   :   0.0   Min.   :30.00  
##  1st Qu.:   0.0   1st Qu.:38.00  
##  Median : 288.0   Median :46.00  
##  Mean   : 740.6   Mean   :45.12  
##  3rd Qu.:1516.0   3rd Qu.:52.00  
##  Max.   :4950.0   Max.   :60.00
```

```r
cor(mydata.sub0)
```

```
##              hours      husage
## hours   1.00000000 -0.03108875
## husage -0.03108875  1.00000000
```

It is important to understand that there is not one correct way to do things, but rather there are many correct ways of doing things.

## Using subsets of data, by filtering observations

An issue you will often encounter is that you want to do some analysis but not on all the observations you have in your dataset. Let's say you wish to calculate the correlation between the hours a women works (`hours`) and the hours her husband works (`hushrs`). But you want to do that only for those women who actually work more than 100 hours a year.

There are multiple ways of doing this (and also check out the [Data Summary using Tidyverse](https://datasquad.github.io/ECLR/Rwork/SummaryStatsTidyverse.html) page for an elegant alternative way of doing so).


```r
mydata.sub1 <- subset(mydata, hours > 100, select = c("hours","hushrs"))
cor(mydata.sub1)
```

```
##              hours      hushrs
## hours   1.00000000 -0.02351165
## hushrs -0.02351165  1.00000000
```


## More summary stats

Above we learned how to calculate summary statistics for numeric variables. If you have categorical variables, like years of education (`educ`) or number of kids younger than 6 years old (`kidslt6`) you actually want to see the number of observations in the categories. You can do this with the `table` function. 


```r
table(mydata$educ)
```

```
## 
##   5   6   7   8   9  10  11  12  13  14  15  16  17 
##   4   6   8  30  25  44  43 381  44  51  14  57  46
```

As you can see the largest group is the women with 12 years of education which is equivalent to high school education. 

If you wanted to see this information not in terms of percentages you could so this as follows:


```r
prop.table(table(mydata$educ))
```

```
## 
##           5           6           7           8           9          10 
## 0.005312085 0.007968127 0.010624170 0.039840637 0.033200531 0.058432935 
##          11          12          13          14          15          16 
## 0.057104914 0.505976096 0.058432935 0.067729084 0.018592297 0.075697211 
##          17 
## 0.061088977
```

Now you can see that just over 50% have a high school education as their highest qualification.

> Create the same type of table to figure out what percentage of women in the sample have no children younger than 6 years. You should find that it is just over 80%




```
## 
##           0           1           2           3 
## 0.804780876 0.156706507 0.034528552 0.003984064
```

There are a lot of digits in this output. You can tell R to show fewer digits. Run the following line and re-run the table with proportions to see the difference


```r
options(digits = 2)
```


Often you may want to create such tables for two rather than only one variable, say both for `educ` and for `kidslt6`. We call tables like this contingency tables or sometime cross tabs.


```r
table(mydata[c("educ","kidslt6")])  # counts
```

```
##     kidslt6
## educ   0   1   2   3
##   5    4   0   0   0
##   6    6   0   0   0
##   7    5   2   1   0
##   8   28   2   0   0
##   9   20   5   0   0
##   10  37   5   2   0
##   11  36   6   1   0
##   12 308  65   8   0
##   13  36   4   2   2
##   14  40   8   3   0
##   15   9   2   2   1
##   16  43  12   2   0
##   17  34   7   5   0
```

Now, presenting thisin terms of percentages is even more important.


```r
prop.table(table(mydata[c("educ","kidslt6")]) ) # percentages
```

```
##     kidslt6
## educ      0      1      2      3
##   5  0.0053 0.0000 0.0000 0.0000
##   6  0.0080 0.0000 0.0000 0.0000
##   7  0.0066 0.0027 0.0013 0.0000
##   8  0.0372 0.0027 0.0000 0.0000
##   9  0.0266 0.0066 0.0000 0.0000
##   10 0.0491 0.0066 0.0027 0.0000
##   11 0.0478 0.0080 0.0013 0.0000
##   12 0.4090 0.0863 0.0106 0.0000
##   13 0.0478 0.0053 0.0027 0.0027
##   14 0.0531 0.0106 0.0040 0.0000
##   15 0.0120 0.0027 0.0027 0.0013
##   16 0.0571 0.0159 0.0027 0.0000
##   17 0.0452 0.0093 0.0066 0.0000
```

You can see that almost 41% of women in the sample had 12 years of education and no children younger than 6 (`educ==12` and `kidslt6 == 0`).

When you show percentages/proportions with multiple variables then you will often want to see conditional probabilities. Say, given a women has high school education (`educ==12`), what is the probability of that women having no children younger than 6 (`kidslt6 == 0`).

The following line of code does give you that result, but what should you replace the "XXXX" with? With "1" or with "2"? Use the help function to understand (`?prop.table`).


```r
prop.table(table(mydata[c("educ","kidslt6")]), margin = XXXX ) # conditional percentages
```

When you get it right you should get the following table:


```
##     kidslt6
## educ     0     1     2     3
##   5  1.000 0.000 0.000 0.000
##   6  1.000 0.000 0.000 0.000
##   7  0.625 0.250 0.125 0.000
##   8  0.933 0.067 0.000 0.000
##   9  0.800 0.200 0.000 0.000
##   10 0.841 0.114 0.045 0.000
##   11 0.837 0.140 0.023 0.000
##   12 0.808 0.171 0.021 0.000
##   13 0.818 0.091 0.045 0.045
##   14 0.784 0.157 0.059 0.000
##   15 0.643 0.143 0.143 0.071
##   16 0.754 0.211 0.035 0.000
##   17 0.739 0.152 0.109 0.000
```

The probability that a women with 12 years of education has no children younger than 6 years old is 80.8%.



## Summary

Here you have learned how to calculate summary statistics to particular variables in a dataset. How to restrict your calculation to particular rows n the dataset and importantly how to produce contingency tables.
