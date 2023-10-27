---
tidytitle: "Summary Statistics with Tidyverse"
author: "RalfBecker"
date: "2023-10-27"
output: 
  html_document: 
    keep_md: yes
---




# Introdution

In this little project we will demonstrate how to use the mightily powerful packages of the "tidyverse" to perform some data analysis. In particular we learn how to perform more advanced filtering and grouping tasks such that data analysis can then be applied to a range of different data slices. Those of you who have some Excel experience may be familiar with pivot tables, and we are aiming to perform tasks that are similar to what pivot tables can do.

So before we do anything else you should install the `tidyverse` package and then load it:


```r
library(tidyverse)
```

By the way, at this stage you should take five minuted to learn about [https://priceonomics.com/hadley-wickham-the-man-who-revolutionized-r/](Hadley Wickham) a real hero for data nerds. And if you think at the end of this section "Wow, that is powerful and quite straightforward" you got him to thank for it.

# Loading a dataset

Let's get a dataset to look at. We shall use the Baseball wages dataset, including 353 Baseball Players in 1993 (get the datafile from the [http://eclr.humanities.manchester.ac.uk/index.php/R#Data_Sets](ECLR page)).


```r
mydata <- read.csv("../data/mlb1.csv")
```

Let's check out what variables we have in this data-file


```r
names(mydata)
```

```
##  [1] "salary"   "teamsal"  "nl"       "years"    "games"    "atbats"  
##  [7] "runs"     "hits"     "doubles"  "triples"  "hruns"    "rbis"    
## [13] "bavg"     "bb"       "so"       "sbases"   "fldperc"  "frstbase"
## [19] "scndbase" "shrtstop" "thrdbase" "outfield" "catcher"  "yrsallst"
## [25] "hispan"   "black"    "whitepop" "blackpop" "hisppop"  "pcinc"   
## [31] "gamesyr"  "hrunsyr"  "atbatsyr" "allstar"  "slugavg"  "rbisyr"  
## [37] "sbasesyr" "runsyr"   "percwhte" "percblck" "perchisp" "blckpb"  
## [43] "hispph"   "whtepw"   "blckph"   "hisppb"   "lsalary"
```

You can find short variable descriptions [here](http://eclr.humanities.manchester.ac.uk/index.php/MLB1_Variable_Description) and of course you need to understand what data types the variables represent (check `str(mydata)` to confirm the R datatypes.) 

You can perhaps see that the positional information is organised in individual positional variables ("frstbase" "scndbase" "shrtstop" "thrdbase" "outfield" "catcher") that take the value 1 if a player plays in a particular position.

To confirm that each player is only assigned one position we calculate the following:


```r
temp <- rowSums(mydata[,c("frstbase","scndbase","shrtstop","thrdbase","outfield","catcher")])
min(temp)
```

```
## [1] 1
```

```r
max(temp)
```

```
## [1] 1
```
As the result is one for both min and max value we have confirmed that every player has been assigned exactly one position. 

A similar situation exists with the ethnicity variable. We have two variables ("hispan" "black") which are 1 if the respective player is ither black or hispanic. If both are 0 the player is white. 

Let us now create two variables ("position" and "race") which summarise the respective information in one variable each.


```r
mydata$position <- "First Base"
mydata$position[mydata$scndbase == 1] <- "Second Base"
mydata$position[mydata$shrtstop == 1] <- "Short Stop"
mydata$position[mydata$thrdbase == 1] <- "Third Base"
mydata$position[mydata$outfield == 1] <- "Outfield"
mydata$position[mydata$catcher == 1] <- "Catcher"
mydata$position <- as.factor(mydata$position)  # now ensure it is a factor variable

mydata$race <- "White"
mydata$race[mydata$hispan == 1] <- "Hispanic"
mydata$race[mydata$black == 1] <- "Black"
mydata$race <- as.factor(mydata$race)   # now ensure it is a factor variable
```


# What variables are you interested in?

Almost the most difficult task in data analysis, in particular if you have data with so many different variables as the dataset here, is to know what you are interested in. Once you know that you have to find ways to slice the data into the right bits before you analyse them. That is the main task to learn here.

## A flashback

Remember a few basis commands before we proceed. If you want a quick summaries for a particular variable in the data frame, say `salary` you use:


```r
summary(mydata$salary)
```

```
##    Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
##  109000  253600  675000 1345672 2250000 6329213
```

```r
summary(mydata$position)
```

```
##     Catcher  First Base    Outfield Second Base  Short Stop  Third Base 
##          52          45         136          37          49          34
```

If you know exactly the particular statistic you are after, you can immediately calculate it as such


```r
max(mydata$salary)
```

```
## [1] 6329213
```
Other useful statistics can be called using the following function: `mean()`, `median()`, `sd()` and `var()`.

## First pipe!

So let's learn by doing.

Let's say we want to see the average salary for each position. First we'll see how we do it and we explain what happened afterwards.


```r
mydata %>% group_by(position) %>% summarise(mean(salary))
```

```
## # A tibble: 6 × 2
##   position    `mean(salary)`
##   <fct>                <dbl>
## 1 Catcher            892519.
## 2 First Base        1586781.
## 3 Outfield          1539324.
## 4 Second Base       1309641.
## 5 Short Stop        1069211.
## 6 Third Base        1382647.
```
Here we used the `%>%` piping operator. What this does is best described in words. Here we did the following: "Thake the dataset mydata, group the data by position and then summarise the data by presenting the mean salary for each group".

We can clearly see that average salaries vary between positions. Amongst the fielding positions included in this dataset, the average salary is highest amongst players on the First Base (closely followed by Outfielders) and lowest for catchers. Note that, although this is a rather old dataset, [http://www.businessinsider.com/chart-mlbs-highest-paid-positions-2014-7?IR=T](this ordering has not changed).

Let's show a few variations here:


```r
mydata %>% group_by(position) %>% summarise(number = length(salary),avg.salary = mean(salary))
```

```
## # A tibble: 6 × 3
##   position    number avg.salary
##   <fct>        <int>      <dbl>
## 1 Catcher         52    892519.
## 2 First Base      45   1586781.
## 3 Outfield       136   1539324.
## 4 Second Base     37   1309641.
## 5 Short Stop      49   1069211.
## 6 Third Base      34   1382647.
```

Here we added another aspect of the above groups to the final display, namely the number of observations. By checking `length(salary)` we are basically finding out how many observations for each position (as that is what we grouped by before) there are. Here, for instance, we see that there are 52 catchers in the database.

Also by not just, in `summarise`, saying `mean(salary)` but rather `avg.salary = mean(salary)` we can rename the column in which the salary mean is displayed.

# Simple pivot tables

Let's start with what I call simple pivot tables. Tables where we group by one variable.

## The core tools

Now we look at each of the main tools in our toolbox

### group_by

The main work in the example above was done by the `group_by` command. The variables by which we group will typically be categorical variables. Often these will be defined as factor variables. But they could also be, for instance, `int` variables, such as `black`.


```r
mydata %>% group_by(black) %>% summarise(length(salary),mean(salary))
```

```
## # A tibble: 2 × 3
##   black `length(salary)` `mean(salary)`
##   <int>            <int>          <dbl>
## 1     0              245       1209602.
## 2     1              108       1654350.
```

Interestingly this would suggest that black players earn higher salaries. However,


```r
mydata %>% group_by(hispan) %>% summarise(length(salary),mean(salary))
```

```
## # A tibble: 2 × 3
##   hispan `length(salary)` `mean(salary)`
##    <int>            <int>          <dbl>
## 1      0              289       1410990.
## 2      1               64       1050723.
```
reveals that it is hispanics that earned significantly less than the others and the full variety is only revealed by using our race variable:


```r
mydata %>% group_by(race) %>% summarise(length(salary),mean(salary))
```

```
## # A tibble: 3 × 3
##   race     `length(salary)` `mean(salary)`
##   <fct>               <int>          <dbl>
## 1 Black                 108       1654350.
## 2 Hispanic               64       1050723.
## 3 White                 181       1265780.
```

On face value these resuts suggest that, on average, black players earn most and hispanic players the least. Of course there are a numer of other factors at play which these very simple summary statistics does not take account of and the three groups very likely differ in other aspects that are relevant for player salary.  

### filter()

The `filter_by` command allows us to remove a subset of the data. Here is how we could use this command if we only wanted to look at players that have not (by 1993) been an All Star player (`yrsallst == 0`).


```r
mydata %>% filter(yrsallst == 0) %>% group_by(position) %>% summarise(number = length(salary),avg.salary = mean(salary))
```

```
## # A tibble: 6 × 3
##   position    number avg.salary
##   <fct>        <int>      <dbl>
## 1 Catcher         42    587167.
## 2 First Base      31    827747.
## 3 Outfield        93    858689.
## 4 Second Base     25    717133.
## 5 Short Stop      38    687741.
## 6 Third Base      21    701786.
```
When comparing this table to the table above we can of course see that we are now looking at fewer players and their salaries are lower.

We can look at all All Stars (`yrsallst > 0`) by changing the input into the `filter` command:


```r
mydata %>% filter(yrsallst > 0) %>% group_by(position) %>% summarise(number = length(salary),avg.salary = mean(salary))
```

```
## # A tibble: 6 × 3
##   position    number avg.salary
##   <fct>        <int>      <dbl>
## 1 Catcher         10   2175000 
## 2 First Base      14   3267500 
## 3 Outfield        43   3011395.
## 4 Second Base     12   2544032.
## 5 Short Stop      11   2387014.
## 6 Third Base      13   2482500
```

immediately seeing that All Stars attract significantly higher salaries (note, this is not a causal relationship!). They are All Stars because they are good players and it is being a good player that earns them a high salary. Of course there may still be a premium for All Stars, but you cannot conclude this from the above statistics.

### arrange()

Let's say you wanted to arrange the table such that positions with lower salaries are shown first. The `arrange` command is the tool you need.



```r
mydata %>% filter(yrsallst == 0) %>% group_by(position) %>% summarise(number = length(salary),avg.salary = mean(salary)) %>% arrange(avg.salary)
```

```
## # A tibble: 6 × 3
##   position    number avg.salary
##   <fct>        <int>      <dbl>
## 1 Catcher         42    587167.
## 2 Short Stop      38    687741.
## 3 Third Base      21    701786.
## 4 Second Base     25    717133.
## 5 First Base      31    827747.
## 6 Outfield        93    858689.
```
Clearly, different positions pay, on average, differently.


# Double pivot tables

These are tables where we group the data by at least two dimensions, say position and race. So in the end we want a table that has positions in rows, race in columns and the respective group averages in the cells.

## group_by() for more than one group


```r
mydata %>% group_by(position,race) %>% summarise(avg.salary = mean(salary))
```

```
## # A tibble: 18 × 3
## # Groups:   position [6]
##    position    race     avg.salary
##    <fct>       <fct>         <dbl>
##  1 Catcher     Black       736000 
##  2 Catcher     Hispanic    970214.
##  3 Catcher     White       887151.
##  4 First Base  Black      1582917.
##  5 First Base  Hispanic    977833.
##  6 First Base  White      1799058.
##  7 Outfield    Black      1728032.
##  8 Outfield    Hispanic   1344532.
##  9 Outfield    White      1319637.
## 10 Second Base Black      1715208.
## 11 Second Base Hispanic   1315357.
## 12 Second Base White      1160343 
## 13 Short Stop  Black      2007098.
## 14 Short Stop  Hispanic    682711.
## 15 Short Stop  White      1103050.
## 16 Third Base  Black      1019889.
## 17 Third Base  Hispanic   1309722.
## 18 Third Base  White      1540992.
```

As you can see it is pretty straightforward to group by more than one variable (you merely add another variable to the `group_by()` command), but we would like to display the result differently (positions in rows and race in columns).

## spread() and arrange()

At this stage it is useful to notice that R returned the above tables in what are known as `tibbles`, which are a type of dataframe. The above result had three variables: `position`, `race` and `avg.salary`, the last being the new display variable we created containing the grouped averages. 

Rearranging the data display such that variation on one of the grouping variables is shown across different columns is achieved as follows:


```r
mydata %>% group_by(position,race) %>% summarise(avg.salary = mean(salary)) %>% spread(race,avg.salary)
```

```
## # A tibble: 6 × 4
## # Groups:   position [6]
##   position       Black Hispanic    White
##   <fct>          <dbl>    <dbl>    <dbl>
## 1 Catcher      736000   970214.  887151.
## 2 First Base  1582917.  977833. 1799058.
## 3 Outfield    1728032. 1344532. 1319637.
## 4 Second Base 1715208. 1315357. 1160343 
## 5 Short Stop  2007098.  682711. 1103050.
## 6 Third Base  1019889. 1309722. 1540992.
```

As you see we merely added the `spread` command at the end, meaning that we send the previous result to the `spread` command. The spread command takes as the first input the variable that should form the colums (here `race`) and as the second input the variable that should show in the cells (here `avg.salary').

To illustrate that you can also group by more than two variables we first create a new variable `AS` which is a boolean variable (TRUE or FALSE) depending on whether a player was an all start in 1993. Then we merely add this new variable into our list of group_by variables.


```r
mydata$AS <- (mydata$yrsallst>0)
mydata %>% group_by(AS,position,race) %>% summarise(avg.salary = mean(salary)) %>% spread(race,avg.salary) %>% arrange(AS)
```

```
## # A tibble: 12 × 5
## # Groups:   AS, position [12]
##    AS    position       Black Hispanic    White
##    <lgl> <fct>          <dbl>    <dbl>    <dbl>
##  1 FALSE Catcher      172000   238300   647153.
##  2 FALSE First Base   625694.  521500  1014194.
##  3 FALSE Outfield     831629.  762221.  931295.
##  4 FALSE Second Base  708750  1014000   626458.
##  5 FALSE Short Stop   269375   510719.  938065.
##  6 FALSE Third Base   553167.  456250   808154.
##  7 TRUE  Catcher     1300000  2800000  2121429.
##  8 TRUE  First Base  3018750  2575000  3565000 
##  9 TRUE  Outfield    3136667. 2975000  2678833.
## 10 TRUE  Second Base 2721666. 2068750  2584036.
## 11 TRUE  Short Stop  4324061. 1600000  1696995.
## 12 TRUE  Third Base  1953333. 3016667  2599537
```

We smuggled one extra tool into this analysis. The last command here is `arrange(AS)`. This merely told R to order the rows in the display table according to the variable `AS`. The rows are ordered in ascending order (as `AS` is a boolean variable that means from FALSE to TRUE). If you wanted a reversed ordering of `AS` and in addition a secondary ordering according to position name you would achieve this by using `arrange(desc(AS),position)` instead.

Looking at this table we can already see that the above result, that black players earn on average more than white players, must have been due to some underlying confounding factor. If you compare each row in the above table you can see that for almost all combinations of position and All Status it is the white players that earn the most (one exception, for instance, being All Star short stops). 

Without even attempting to settle this for good, we will take one more step to investigating this by looking at the number of players of different races in the different positions.


```r
mydata %>% group_by(AS,position,race) %>% summarise(number = length(salary)) %>% spread(race,number) %>% arrange(AS)
```

```
## # A tibble: 12 × 5
## # Groups:   AS, position [12]
##    AS    position    Black Hispanic White
##    <lgl> <fct>       <int>    <int> <int>
##  1 FALSE Catcher         1        5    36
##  2 FALSE First Base      6        7    18
##  3 FALSE Outfield       44       14    35
##  4 FALSE Second Base     4        5    16
##  5 FALSE Short Stop      4       16    18
##  6 FALSE Third Base      6        2    13
##  7 TRUE  Catcher         1        2     7
##  8 TRUE  First Base      4        2     8
##  9 TRUE  Outfield       28        5    10
## 10 TRUE  Second Base     4        2     6
## 11 TRUE  Short Stop      3        3     5
## 12 TRUE  Third Base      3        1     9
```
This paints an interesting picture. The vast majority of black professional baseball players (at least on the fielding positions) played as Outfielders and these were quite well paid positions. This is the reason why the overall average appeared to be highest for black players.

# Summary

Through this small exercise you got a taste of how to use the mighty piping technique. Once you understand the architecture of the commands you will realise that this is an almighty technique. 


