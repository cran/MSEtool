The current version of the `MSEtool` package is available for download from [CRAN](https://CRAN.R-project.org/package=MSEtool).

## MSEtool 3.0.2

### Updates
- Help description has been updated for `Stock`, `Fleet`, and `Obs` objects (many thanks to Sarah Valencia).

### Fixes
- fix minor bugs in `XL2Data` for importing data from CSV

## MSEtool 3.0.1 

### Minor Changes
- Add `I_beta`, `SpI_beta`, and `VI_beta` for the individual indices. Defaults to use `OM@beta` for all, unless a real
index is supplied, e.g., `OM@cpars$Data@Ind`, `OM@cpars$Data@SpInd`, or `OM@cpars$Data@VInd`, or if supplied in cpars, 
e.g., `OM@cpars$I_beta`

### Fixes
- fix bug where variability in von Bert *K* with `OM@Ksd` was not implemented correctly (5e6e8c6).
- fix error with incorrect beta values when conditioning with real index (ie cpars$Data@Ind)
- fix randomly occurring bug in C++ code that was causing crashes
- fix issue with importing composition data with `new('Data',..)` (issue #33)
- fix `cpars$beta` and `cpars$Esd` issue (issue #34)
- fix issue with importing Data files from csv

## MSEtool 3.0.0
This is a new major release of the `MSEtool` package. It is not backwards compatible with previous versions of `MSEtool` or `DLMtool`.

### Major Changes
- The most significant change in this version is that the `MSEtool` package now contains all code related to generating operating models, simulating fisheries dynamics, conducting management strategy evaluation, and examining the results (previously in the `DLMtool` package). This change was primarily done to better align the actual contents of the packages with the respective package names.
- `MSEtool` now only has a set of reference management procedures (e.g., `FMSYref`)
- The [Data-Limited Methods Toolkit](https://github.com/Blue-Matter/DLMtool) package now contains the collection of data-limited methods, and uses `MSEtool` V3+ as a dependency; i.e., installing and loading `DLMtool` will also install and load `MSEtool` and make all functions for generating OMs, conducting MSE, etc available. 
- The operating model has been updated and an age-0 age-class has been added to the population dynamics model; i.e., recruitment is now to age-0 (previously the OM in `DLMtool` had recruitment to age-1).
- The catch-at-age (CAA) in the `Data` object now includes age-0 (i.e., all age data must be length `maxage+1`)
