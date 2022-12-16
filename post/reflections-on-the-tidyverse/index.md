---
title: Reflections on the tidyverse
author: Philip Khor
date: '2019-07-07'
slug: reflections-on-the-tidyverse
categories: [R, tidyverse]
subtitle: 'Why I like (and use) the tidyverse'
lastmod: '2019-07-07T17:20:14+09:00'
image: featured.png
---

At my previous gig as a junior data scientist trainer, my team was given some time to revamp our base R-based syllabus to be more tidy-friendly while retaining significant base-R content.

This article is not written as an introduction to the tidyverse. It assumes you already work with the tidyverse, and is really just me jotting down my notes from the revamp exercise.

## The tidyverse is opinionated

There's decisions made for your own good, and that's bound to split people. For example, you [can't make dual y-axis charts in `ggplot2`](https://stackoverflow.com/questions/3099219/ggplot-with-2-y-axes-on-each-side-and-different-scales). And that's probably for the best (imo).

## The tidyverse is designed to be readable

After skimming over base data structures, I start out my `dplyr` classes not showing users anything but a code chunk something like this

``` r
mtcars %>%
  rownames_to_columns() %>% 
    select(cyl, mpg) %>% 
    filter(cyl == 1) %>% 
    arrange(mpg) %>% 
    mutate(litres_per_100km = mpg * 6.72)
```

and asking students to guess what the code is doing. While I tested this on only two groups of students, generally this example made sense, and is a great motivation to use the tidyverse.

For me, starting out with skimming over base basics is probably the ideal approach. At the least, cover basic atomic vectors and lists. It'd be difficult to show how to use functions operating on vectors in `mutate()` (and maybe the `.data` pronoun) with limited experience in base otherwise.

As we designed the course, we discovered that `dplyr` had convenient database backends that connect to SQL and Spark, and this was an added motivation for learning `dplyr` syntax well.

## The tidyverse is designed to be safe

I take safety in the tidyverse to mean anticipate user mistakes and to guard against these mistakes. I think they call it 'defensive programming'? However I concede most of the progress in safety is with `purrr` and less so in `dplyr` (my impression).

1.  **No side-effects** A key principle in the design of `dplyr` functions is that the function should not affect the original data frame. We designed our material in Jupyter Notebooks, where [out-of-order execution](https://yihui.name/en/2018/09/notebook-war/#1-hidden-state-and-out-of-order-execution) was an issue. In the context of material designed in Jupyter Notebooks, a no-side-effects workflow is advantageous, since if you run cells out of order, you could potentially get different results. This is less of a problem in R Markdown because the user is encouraged to knit the document. pandas seems to be headed in a similar direction, deprecating the `inplace = True` argument altogether and encouraging the use of method chaining.

2.  **safer functions**: The tidyverse includes type-safe versions of base functions such as `if_else()`vs. `ifelse()` and especially type-safe functional programming (`purrr::map()` functions vs. `sapply()` with its set of simplification rules).

## Pipes are good, but to teach?

R `magrittr` pipes were inspired by UNIX pipes. While I'm not familiar with using them, they've been around for a while.

Pipes, combined with `dplyr` verbs, provide a SQL-like logic to your code. In R for Data Science, the authors compare

`x(y(z(a)))`

`a %>% z() %>% y() %>% x()`

where the first example is less human-readable, since it doesn't follow the sequence of operations performed.

Pandas [method chaining](https://tomaugspurger.github.io/method-chaining) uses a similar workflow. I'm so used to using `dplyr` now, the first thing I look up before doing a data analysis project on tabular data in Python is the corresponding methods in `pandas` for the `dplyr` verbs. While I'm less familiar with the pandas methods, using them in conjunction with method chaining make for much more readable code, and using them is a priority for me if I'm doing extensive analysis in pandas.

I'm not sure if pipes are easy to teach for most audiences given my limited experience, but they are critical to teaching in the tidyverse imo. It's worked for me so far, but students often forget about the first argument.

## Consistent design

tidyverse functions have generally consistent design. For learners, this generally means learning a few functions allows you to reuse that knowledge with other functions with relative ease. tidyverse functions and packages offer consistent arguments across functions and packages, e.g. `readr`, `readxl`.

The biggest common denominator across the tidyverse is the data-first paradigm. An example how this helps is how it may be easier to teach functional programming in `purrr` compared to base R, since the multivariate versions of the `apply` functions contain the data within the ellipsis argument, which is the *last* argument, versus with `lapply()`/`sapply()` where the data is the *first* argument.

The `tidyverse` is designed as a grammar, or perhaps a way to speak about the operations you're running. `dplyr` is the tidyverse's grammar for manipulating tabular data encapsulated in 6 verbs and their variants, whereas `ggplot2` is the tidyverse's grammar for constructing charts.

Within the tidyverse grammar, every function is a verb. I particularly like the classification of the join verbs as mutating and filtering joins. It's a useful heuristic for me to decide which join to use.

## Small core function set (relative to pandas?)

A common way to teach `dplyr`, as I found in many tutorials, is to help students master the 6 core `dplyr` functions **first**. I emphasise while teaching that functions such as `rename()` are shortcuts for these 6 functions, and there are always workarounds to do what you need even if you can't find/don't remember the shortcuts. It takes pressure off the student to 'remember `everything()`'.

``` r
mtcars %>% 
    rename(miles_per_gallon = mpg)

# is equivalent to
mtcars %>% 
    select(miles_per_gallon = mpg, everything())
# provided you don't care about the ordering of the columns
```

## Tibbles are *simpler*

There are only two differences between the base data frame and the tibble: (1) a different print method that considers console size and (2) not allowing rownames. (If you go by R4DS, tibbles are more restrictive and complain more) If anything students don't need to learn about row names, because frankly they don't need them. (Wrangling MultiIndex is something I certainly don't miss from pandas ... )

The requirement for **tidy data** is shared between `ggplot2` and `seaborn`. Tidy data seems to get less emphasis in the Python ecosystem (this [pandas course](https://tomaugspurger.github.io/modern-5-tidy) seems to be an excellent exception), and students didn't have a good mental model for thinking about how to prepare their data before plotting or modelling.

## Base R pains

Still having not worked much with R, I didn't get the pains with base until after reading a few chapters in R for Data Science. `is.vector()` for example returns `TRUE` for a list, because a list is just a recursive vector. This is annoying if you wanted to simplify the teaching of atomic vectors as *vectors* and the students try running `is.vector()` ...

`stringsAsFactors = TRUE` in `read.csv` is a less-than-ideal default for data analysis. The argument defines the order of the factor levels before the user manipulates them, and the user is unaware of the order of the factor levels. If the user isn't aware of the default, data analysis can be a bit of a pain. (Although I concede that `read_csv()` has failed me on one occasions. However, I never understood reprex well enough to file a good bug when it happened. )

We've been bitten by the ellipsis (`...`) argument in functions such as `mean()`. Because of the ellipsis argument, the following lines of code run without error:

``` r
# rm.na is not a valid named argument, but no error is returned
mean(c(1, 2, 3), rm.na = TRUE)
# returns 1
mean(1, 2, 3)
```

## Emphasis on code style from the outset

The tidyverse emphasises using a consistent casing for objects. Snake case is preferred across all objects. `janitor::clean_names()` is a great way to enforce this, to coerce all column names to snakecase. It's easy to promote the perks of consistent code style to students given good examples and opinionated design in the tidyverse. Having to use backticks as escape characters otherwise is a good motivation for using `janitor::clean_names()`.

One thing I like about teaching `dplyr` functions is that they implicitly discourage integer indexing in favour of making filtering/selecting decisions explicit, although it is still possible, for instance,

``` r
df %>% select(1:3)
df %>% slice(4:6)
```

One could argue indexing is still required for data partitions for predictive modelling, but I'd argue `rsample` circumvents that

``` r
library(rsample)
df_split <- initial_split(df)
df_train <- training(df_split)
df_test <- testing(df_split)
```

Of course, there's always `dplyr::sample_n()` and `dplyr::sample_frac()`, which can be used in conjunction with a filtering join:

``` r
df %>% sample_frac(.8) -> df_train
df %>% anti_join(df_train) -> df_test
```

## Debugging

It is very true that debugging in a long series of pipes can be a pain, and I think `dplyr` should provide more messages. Stata has [useful reports](https://twitter.com/AnnaMBokun/status/1146289574999678977) on operations that `dplyr` can benefit from implementing, and independent efforts such as [tidylog](https://github.com/elbersb/tidylog) help report the outcomes of data wrangling.

## Conclusions

There are parts I still find awkward to teach in the tidyverse.

-   Like how to explain how symbols work when used in `dplyr` functions. Teaching it as 'exposes the vectors within a data frame within an environment' just doesn't seem very beginner-friendly, and I need to find a simpler way.\
-   The multitude of packages to teach to accomplish different tasks gets annoying at times (I wish I could start off with `here()` as soon as we talk about importing data without confusing students with an additional import!).
-   I wish `dplyr` returns a warning when removing rownames because users aren't aware that the rownames are being dropped (but the only use case here is `mtcars`, really ...).
-   I still get `top_n()` wrong. All the time.
-   And don't even get me started with tidyeval ...

My teaching philosophy is to teach people to work with data efficiently with good data analysis workflows, not to become package authors (although that'd be nice!). I find that `dplyr` helps me think about my analysis faster. I don't deal with datasets so big that I really care how long my code takes to run, so long as I do it right. But my teaching days are over ... for now.
