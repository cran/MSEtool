% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/Misc_Exported.R
\name{tinyErr}
\alias{tinyErr}
\alias{tinyErr,OM-method}
\title{Remove observation, implementation, and process error}
\usage{
tinyErr(x, ...)

\S4method{tinyErr}{OM}(x, obs = TRUE, imp = TRUE, proc = TRUE, grad = TRUE, silent = FALSE)
}
\arguments{
\item{x}{An object of class \code{OM}}

\item{...}{Arguments to generic function}

\item{obs}{Logical. Remove observation error? \code{Obs} is replaced with \code{Perfect_Info}}

\item{imp}{Logical. Remove implementation error? \code{Imp} is replaced with \code{Perfect_Imp}}

\item{proc}{Logical. Remove process error? All \code{sd} and \code{cv} slots in \code{Stock}
and \code{Fleet} object are set to 0.}

\item{grad}{Logical. Remove gradients? All \code{grad} slots in \code{Stock} and
\code{qinc} in \code{Fleet} are set to 0.}

\item{silent}{Logical. Display messages?}
}
\value{
An updated object of class \code{OM}
}
\description{
Takes an existing OM object and converts it to one without any observation
error, implementation error, very little process error, and/or gradients in
life history parameters and catchability.
}
\details{
Useful for debugging and testing that MPs perform as expected under perfect conditions.
}
\examples{
OM_noErr <- tinyErr(MSEtool::testOM)
}
