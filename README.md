# R and python usages

This repo is an attempt to use data to explore the claims in [Python Displacing R As The Programming Language For Data Science](http://t.co/jdR2WF4Kjg) and [The homogenization of scientific computing, or why Python is steadily eating other languages’ lunch](http://bit.ly/1geFq6e).

The individual files contain the R code that I used to gather data from each source, and the results are summarised below. I've made no attempt to separate python for data analysis from other uses of python, but hopefully the signals are still indicative. If you think my methodology is wrong, or you have other ideas for data sets, please send a pull request.

## Stackoverflow questions

Using the [stackexchange data explorer](http://data.stackexchange.com/stackoverflow/query/150128/r-questions-per-month), I calculated the number of questions asked by month for both python and R. Overall, both R and python questions are growing explosively over time:

![Explosive growth of R and python questions over time](images/so-raw.png)

A little further exploration (not shown) indicates that this is very close to being exponential growth.  

If we standardise the number of R questions by the number of python questions, we see that R the number of R questions is increasing more rapidly than python. Currently, about 1 question about R is asked for every four questions asked about python.

![R questions growing relative to python](images/so-rel.png) 
