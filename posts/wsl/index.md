---
summary: Why and how to use R from WSL2.
authors: []
author: null
slug: wsl
lastmod: 2020-08-27T22:46:02+08:00
title: WSL2 and R
subtitle: ""
date: 2020-08-27
featured: no
tags: []
categories: []
projects: []
image:
  caption: ""
  focal_point: ""
  preview_only: true
---
Windows Subsystem for Linux (WSL) is a great way to run Linux software on your computer without dual-booting or starting over. For certain reasons, you may want to run R in Linux instead of Windows, and WSL can help. 

As of the time of writing, the current version of WSL is WSL2.

## Why bother?

That's a good question. R does work fine with Windows, at least as far as I use it. And in general I think that would be the case for most people. Using R with Windows has the big advantage of having binaries on CRAN available for the latest version of packages. In comparison, Linux does not, however if you use RStudio Package Manager as a package source you'll have access to [package binaries for Linux](https://packagemanager.rstudio.com/). 

With R 4.0, compiling packages requires Rtools4.0, which requires [adding the Rtools home to the .Renviron file](https://cran.r-project.org/bin/windows/Rtools/). While I haven't had problems with this setup, I've seen people facing issues on Twitter. Thank goodness we don't have to install arbitrary Visual Studio dependencies like with some Python packages ...

Essentially, I think you may want to consider using WSL2 with R if you anticipate having compilation issues for your packages on Windows that could be sidestepped by using Linux.

Downloading R binaries from conda is a great alternative, but conda's pretty heavy and I wouldn't recommend running R from conda in parallel with R, at least on Windows. This is because in my experience, the conda R instance looks for packages in the non-conda package library. This is something that's [being worked on](https://github.com/conda-forge/r-base-feedstock/pull/65); in addition, if you install packages from GitHub, it's probably not a great idea to mix that with your conda R library.  

## Okay that's great, but I want to keep my IDE!

Running GUIs from WSL2 is a [work-in-progress](https://www.omgubuntu.co.uk/2020/05/run-linux-apps-on-windows-10-wsl-2). I think the most straightforward solution at this point is to use RStudio Server , which essentially allows you to use RStudio in a browser. 

As with installing R on Windows, you'll want to install R first. [This tutorial](https://www.digitalocean.com/community/tutorials/how-to-install-r-on-ubuntu-20-04#step-2-%E2%80%94-installing-r-packages-from-cran) will help you install R using apt. Then, you'll want to follow the instructions [here](https://support.rstudio.com/hc/en-us/articles/360049776974-Using-RStudio-Server-in-Windows-WSL2) for installing RStudio Server. 

Once you're done, run 

```
sudo rstudio-server start
```

in your WSL terminal.

## Transferring files

That's not too much of a problem actually. Once you start wsl, you can access your Linux file system using `//wsl$`.