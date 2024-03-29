% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/RcppExports.R
\name{popdynOneTScpp}
\alias{popdynOneTScpp}
\title{Aging and Mortality for one time-step}
\usage{
popdynOneTScpp(nareas, maxage, Ncurr, Zcurr, plusgroup = 1L)
}
\arguments{
\item{nareas}{The number of spatial areas}

\item{maxage}{The maximum age}

\item{Ncurr}{A numeric matrix (maxage+1, nareas) with current numbers-at-age in each area}

\item{Zcurr}{A numeric matrix (maxage+1, nareas) with total mortality-at-age in each area}
}
\description{
Project population forward one time-step given current numbers-at-age and total mortality
}
\author{
A. Hordyk
}
\keyword{internal}
