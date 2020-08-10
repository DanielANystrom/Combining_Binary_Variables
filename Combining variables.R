#Title: Method for Combining Variables ####
#Daniel Nystrom
#August 10, 2020

#Working with survey data a lot, I often have a need
#to combine multiple variables together to create
#a single variable as programs such as Qualtrics tend
#to break up questions like this:
#
#Question 1 - What is your favorite color?
#(a) - Green
#(b) - Blue
#(c) - Other
#
#Into three separate variables Q1_a, Q1_b, Q1_c, with
#the each column containing one of two values:
#"<Answer>" and "Not selected". Sometimtes it makes
#sense to keep the answers siloed in this manner, but
#for many analyses (ANOVA, t-tests, MCA, etc.) it makes
#more sense to have a single column for each respondents'
#answers. 
#
#Although this is relatively easy to fix in programs like
#MS Excel using the =if() function, I haven't yet found either
#a package in R, or an easy work-around through online boards.
#So, this is one method I've tried and started using that
#seems to work pretty well without much stress.

#Load the tidyverse package, if not already loaded
if(!require(tidyverse)) install.packages("tidyverse")
library(tidyverse)

#First, we either import the data or, here, create a sample
#tibble for demonstration purposes:
df <- tibble(
    A = c(1, 0, 0), #'0' represents a non-answer, e.g. "Not selected"
    B = c(0, 2, 0), #non-'0' represents an answer, e.g. "Blue"
    C = c(0, 0, 3)
  ) %>%
  print()

#The goal, ultimately, is to create a column that contains
#just the answers without non-answers. So, using ifelse()
#functions here we're able to just declare a new variables on the
#condition that the value be greater than 0 (a non-answer):
df$Combined <- ifelse( #declare the new variable
  df$A > 0, #if A has an answer
  1, #save that answer
  ifelse( #else look at the next column
    df$B > 0,
    2,
    ifelse(
      df$C > 0,
      3,
      NA #Depending on the case, NA might not be necessary
    )))
head(df) #And now there's a tidier variable!

#The real strength of this method though is for more complex
#situations where, as in the following tibble:
df1 <- tibble(
  A = c("Blue", "No answer", "No answer", "No answer", "Blue", "No answer"),
  B = c("No answer", "No answer", "Green", "No answer", "No answer", "No answer"),
  C = c("No answer", "Red", "No answer", "No answer", "No answer", "No answer"),
  D = c("Orange", "No answer", "No answer", "Orange", "No answer", "No answer")
) %>%
  print()
#Here we have four columns, representing six respondents'
#favorite colors, and maybe we want a single column denoting
#whether the respondent likes cool-colors, warm-colors, both,
#or neither.

#In this case the only difference is we're adding in additional
#coditional logic
df1$colors <- ifelse(
  (df1$A == "Blue" | df1$B == "Green"), #check for cool colors
  ifelse( #if true, check for warm colors
    (df1$C == "Red" | df1$D == "Orange"),
    "Both colors",
    "Cool colors"),
  ifelse( #if false, check for warm colors again
    (df1$C == "Red" | df1$D == "Orange"),
    "Warm colors",
    "Neither color"
  )
)
head(df1) #and there you go!

#After that, I sometimes drop the original variables if I know
#I won't need them for subsequent analysis
df1 <- df1 %>%
  select( -c(A, B, C, D)) %>%
  print()

#It is possible there's a better way to accomplish this that
#I just haven't found yet, but so far, I'm finding this pretty
#workable. The big drawback comes if you're combining more than
#5-6 variables, but that's an area for future development.