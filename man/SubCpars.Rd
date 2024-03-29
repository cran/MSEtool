% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/Misc_Exported.R
\name{SubCpars}
\alias{SubCpars}
\alias{SubCpars,OM-method}
\alias{SubCpars,MOM-method}
\title{Subset the cpars slot in an operating model}
\usage{
SubCpars(x, ...)

\S4method{SubCpars}{OM}(x, sims = 1:x@nsim, proyears = x@proyears, silent = FALSE)

\S4method{SubCpars}{MOM}(x, sims = 1:x@nsim, proyears = x@proyears, silent = FALSE)
}
\arguments{
\item{x}{An object of class \linkS4class{OM} or \linkS4class{MOM}}

\item{...}{Arguments for method.}

\item{sims}{A logical vector of length \code{x@nsim} to either retain (TRUE) or remove (FALSE).
Alternatively, a numeric vector indicating which simulations (from 1 to nsim) to keep.}

\item{proyears}{If provided, a numeric to reduce the number of projection years (must be less than \code{x@proyears}).}

\item{silent}{Logical to indicate if messages will be reported to console.}
}
\value{
An object of class \linkS4class{OM} or \linkS4class{MOM} (same class as \code{x}).
}
\description{
Subset the custom parameters of an operating model by simulation and projection years
}
\details{
Useful function for running \link{multiMSE} in batches if running into memory constraints.
}
\seealso{
\link{Sub} for MSE objects, \link{SubOM} for OM components.
}
\author{
T. Carruthers, Q. Huynh
}
