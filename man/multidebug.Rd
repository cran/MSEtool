% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/MMSE_plots.R
\name{multidebug}
\alias{multidebug}
\title{A basic comparison of runMSE output (MSE) and multiMSE (MMSE)}
\usage{
multidebug(MSEsingle, MSEmulti, p = 1, f = 1, MPno = 1, maxsims = 4)
}
\arguments{
\item{MSEsingle}{An object of class MSE arising from a run of runMSE(OM, ...)}

\item{MSEmulti}{An object of class MMSE arising from a run of multiMSE(MOM, ...)}

\item{p}{Integer. The stock number from the MSEmulti object (to be plotted)}

\item{f}{Integer. The fleet number from the MSEmulti object (to be plotted)}

\item{MPno}{Integer. The MP number from the MSEmulti and MSEsingle object (to be plotted)}

\item{maxsims}{Integer. The maximum number of simulations to plot.}
}
\description{
A basic comparison of runMSE output (MSE) and multiMSE (MMSE)
}
\author{
T.Carruthers
}
