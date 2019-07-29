% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/multiMSE.R
\name{multiMSE}
\alias{multiMSE}
\title{Run a multi-fleet multi-stock Management Strategy Evaluation}
\usage{
multiMSE(MOM, MPs = list(c("AvC", "DCAC"), c("FMSYref", "curE")),
  CheckMPs = FALSE, timelimit = 1, Hist = FALSE, ntrials = 50,
  fracD = 0.05, CalcBlow = FALSE, HZN = 2, Bfrac = 0.5,
  AnnualMSY = TRUE, silent = FALSE, PPD = FALSE, parallel = FALSE,
  save_name = NULL, checks = FALSE, control = NULL)
}
\arguments{
\item{MOM}{A multi-fleet multi-stock operating model (class 'MOM')}

\item{MPs}{A matrix of methods (nstock x nfleet) (character string) of class MP}

\item{CheckMPs}{Logical to indicate if \link{Can} function should be used to check
if MPs can be run.}

\item{timelimit}{Maximum time taken for a method to carry out 10 reps
(methods are ignored that take longer)}

\item{Hist}{Should model stop after historical simulations? Returns a list
containing all historical data}

\item{ntrials}{Maximum of times depletion and recruitment deviations are
resampled to optimize for depletion. After this the model stops if more than
percent of simulations are not close to the required depletion}

\item{fracD}{Maximum allowed proportion of simulations where depletion is not
close to sampled depletion from OM before model stops with error}

\item{CalcBlow}{Should low biomass be calculated where this is the spawning
biomass at which it takes HZN mean generation times of zero fishing to reach
Bfrac fraction of SSBMSY}

\item{HZN}{The number of mean generation times required to reach Bfrac SSBMSY
in the Blow calculation}

\item{Bfrac}{The target fraction of SSBMSY for calculating Blow}

\item{AnnualMSY}{Logical. Should MSY statistics be calculated for each projection year?
May differ from MSY statistics from last historical year if there are changes in productivity}

\item{silent}{Should messages be printed out to the console?}

\item{PPD}{Logical. Should posterior predicted data be included in the MSE object Misc slot?}

\item{parallel}{Logical. Should the MSE be run using parallel processing?}

\item{save_name}{Character. Optional name to save parallel MSE list}

\item{checks}{Logical. Run tests?}

\item{control}{control options for testing and debugging}
}
\value{
A hierarchical list (by stock then fleet) of objects of class \linkS4class{MSE}
}
\description{
A function that runs a Management Strategy Evaluation (closed-loop
simulation) for a specified operating model
}
\author{
T. Carruthers and A. Hordyk
}