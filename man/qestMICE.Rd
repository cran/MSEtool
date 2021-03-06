% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/multi_q_estimation.R
\name{qestMICE}
\alias{qestMICE}
\title{Internal function for optimizing catchability (q) for a MICE model}
\usage{
qestMICE(
  par,
  depc,
  CFc,
  mode = "opt",
  np,
  nf,
  nyears,
  nareas,
  maxage,
  Nx,
  VFx,
  FretAx,
  Effind,
  distx,
  movx,
  Spat_targ,
  M_ageArrayx,
  Mat_agex,
  Asizex,
  Kx,
  Linfx,
  t0x,
  Mx,
  R0x,
  R0ax,
  SSBpRx,
  SSB0x,
  hsx,
  aRx,
  bRx,
  ax,
  bx,
  Perrx,
  SRrelx,
  Rel,
  SexPars,
  x,
  plusgroup,
  optVB,
  VB0x,
  maxF
)
}
\arguments{
\item{par}{Integer, the simulation number}

\item{depc}{Numeric vector, nstock long of specified stock depletion (SSB now / SSB0)}

\item{CFc}{Matrix \verb{[nstock, nfleet]}, a catch fraction among fleets (sums to 1 for each stock (row))}

\item{nf}{Integer, number of fleets}

\item{nyears}{Integer, number of historical years (unfished til today)}

\item{nareas}{Integer, number of areas (default is 2)}

\item{maxage}{Integer, maximum number of age classes for calculation}

\item{Nx}{Array \verb{[stock, age, year, area]} of stock numbers}

\item{VFx}{Array \verb{[fleet, age, year, area]} of the vulnerability curve}

\item{FretAx}{Array \verb{[fleet, age, year, area]} of the retention curve}

\item{Effind}{Array \verb{[fleet, year]} of effort}

\item{movx}{Array \verb{[stock,age,area,area]} of movement transitions}

\item{Spat_targ}{Matrix \verb{[stock, fleet]} of spatial targeting parameter (0 evenly spatial distributed, 1 proportional to vulnerable biomass)}

\item{M_ageArrayx}{Array \verb{[stock, age,year]} of Natural mortality rate at age}

\item{Mat_agex}{Array \verb{[stock, age, year]} of maturity (spawning fraction) age age}

\item{Asizex}{Matrix \verb{[stock, area]} Area size}

\item{Kx}{Vector \verb{[stock]} of von B growth parameter K}

\item{Mx}{Vector \verb{[stock]} mature natural mortality rate}

\item{R0x}{Vector \verb{[stock]} unfished recruitment}

\item{R0ax}{Matrix \verb{[stock, area]} unfished recruitment by area}

\item{SSBpRx}{Matrix \verb{[stock, area]} spawning biomass per recruit by area}

\item{SSB0x}{Vector \verb{[stock]} Unfished spawning stock biomass}

\item{hsx}{Vector \verb{[stock]} steepness of the stock recruitment curve}

\item{aRx}{Vector \verb{[stock]} stock recruitment parameter alpha (for Ricker curve)}

\item{bRx}{Vector \verb{[stock]} stock recruitment parameter beta (for Ricker curve)}

\item{ax}{Vector \verb{[stock]} weight-length parameter a W=aL^b}

\item{bx}{Vector \verb{[stock]} weight-length parameter b W=aL^b}

\item{Perrx}{Matrix \verb{[stock, year]} process error - the lognormal factor for recruitment strength}

\item{SRrelx}{Integer vector \verb{[stock]} the form of the stock recruitment relationship (1 = Beverton-Holt, 2= Ricker)}

\item{Rel}{A list of inter-stock relationships see slot Rel of MOM object class}

\item{SexPars}{A list of sex-specific dynamics (SSBfrom, stcck_age)}

\item{x}{Integer. The simulation number}

\item{mod}{Character if 'opt' qestMICE returns the objective function otherwise the fitted values in a list}

\item{Linf}{Vector \verb{[stock]} of von B asymptotic length parameter Linf}

\item{t0}{Vector \verb{[stock]} of von B theoretical age at zero length (t0)}
}
\description{
Function returns objective function that fits both stock depletion and catch fraction among fleets
}
\author{
T.Carruthers
}
\keyword{internal}
