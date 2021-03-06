% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/DFO.R
\name{DFO_report}
\alias{DFO_report}
\title{Create a standard DFO MSE report}
\usage{
DFO_report(
  MSEobj,
  output_file = NA,
  author = "Author not specified",
  title = NA,
  maxMPs = 15
)
}
\arguments{
\item{MSEobj}{An object of class MSE}

\item{output_file}{The directory and filename you wish to use for the report e.g. "C:/temp/myMSEreport.html"}

\item{author}{The person who made this report}

\item{title}{The title of the report}

\item{maxMPs}{Maximum number of MPs to plot}
}
\description{
Provides performance plots typical in the assessment of Canadian fish stocks.
}
\author{
T. Carruthers
}
