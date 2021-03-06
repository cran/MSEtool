% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/Data_make_update.R
\name{simCAA}
\alias{simCAA}
\title{Simulate Catch-at-Age Data}
\usage{
simCAA(nsim, yrs, n_age, Cret, CAA_ESS, CAA_nsamp)
}
\arguments{
\item{nsim}{Number of simulations}

\item{yrs}{Number of years}

\item{n_age}{Number of age classes}

\item{Cret}{Retained Catch at age in numbers - array(sim, years, maxage+1)}

\item{CAA_ESS}{CAA effective sample size}

\item{CAA_nsamp}{CAA sample size}
}
\value{
CAA array
}
\description{
CAA generated with a multinomial observation model from retained catch-at-age
data
}
