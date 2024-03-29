


#' Generic Trade-Plot Function
#'
#' @param MSEobj An object of class `MSE`
#' @param ... Names of Performance Metrics (PMs), or other arguments to `TradePlot`. First PM is recycled if number of PMs is not even
#' @param Lims A numeric vector of acceptable risk/minimum probability thresholds. Recycled if not equal to number of PMs.
#' @param Title Optional title for each plot. Character vector of `length(PMs)`/2. Recycled.
#' @param Labels Optional named list specifying new labels for MPs. For example: `Labels = list(AvC="Average Catch", CC1="Constant Catch")`
#' @param Satisficed Logical. Show only the MPs that meet minimum acceptable thresholds (specified in `Lims`)
#' @param Show Character. Show the plots ('plots'), results table ('table'), 'both' (default), or invisibly return objects only ('none')
#' @param point.size Numeric. Size of the MP points
#' @param lab.size Numeric. Size of MP label. Set to NULL to remove MP labels.
#' @param axis.title.size Numeric. Size of axis titles
#' @param axis.text.size Numeric. Size of axis text
#' @param legend Logical. Include legend?
#' @param legend.title.size Numeric. Size of legend title text
#' @param position Character. Position of legend - 'right' or 'bottom'
#' @param cols Optional character vector of colors for the legend (MP Types) or if `cols` is a character vector of length `MSEobj@nMPs`,
#' then the MP labels are colored (no color legend).
#' @param fill Character. Color of the fill
#' @param alpha Numeric. Transparency of fill
#' @param PMlist Optional list of PM names. Overrides any supplied in ... above
#' @param Refs An optional named list (matching the PM names) with numeric values to override the default `Ref` values. See examples.
#' @param Yrs An optional named list (matching the PM names) with numeric values to override the default `Yrs` values. See examples.


#' @author A. Hordyk
#' @return Invisibly returns a list with summary table of MP performance and
#' the ggplot objects for the plots
#' @export
#'
TradePlot <- function(MSEobj, ..., Lims=c(0.2, 0.2, 0.8, 0.8),
                      Title=NULL,
                      Labels=NULL,
                      Satisficed=FALSE,
                      Show='both',
                      point.size=2,
                      lab.size=4,
                      axis.title.size=12,
                      axis.text.size=10,
                      legend=TRUE,
                      legend.title.size=12,
                      position = c("right", "bottom"),
                      cols=NULL,
                      fill="gray80",
                      alpha=0.4,
                      PMlist=NULL,
                      Refs=NULL,
                      Yrs=NULL
                      ) {
  if (!methods::is(MSEobj, 'MSE') & !methods::is(MSEobj,'MMSE'))
    stop("Object must be class `MSE` or class `MMSE`", call.=FALSE)

  if (methods::is(MSEobj,'MMSE')) legend <- FALSE
  if (!requireNamespace("ggrepel", quietly = TRUE)) {
    stop("Package \"ggrepel\" needed for this function to work. Please install it.",
         call. = FALSE)
  }

  if (is.null(PMlist)) {
    PMlist <- unlist(list(...))
  } else {
    PMlist <- unlist(PMlist)
  }
  position <- match.arg(position)

  if(length(PMlist) == 0) PMlist <- c("STY", "LTY", "P10", "AAVY")
  if (!methods::is(PMlist, 'character')) stop("Must provide names of PM methods")
  # check

  # for (X in seq_along(PMlist))
  #   if (!class(PMlist[X]) =="PM") stop(PMlist[X], " is not a valid PM method")
  if (length(PMlist)<2) stop("Must provided more than 1 PM method")

  if (is.null(cols)) {
    cols <- c("#1b9e77", "#d95f02", "#7570b3", "#e7298a")
  }

  if (length(cols) == MSEobj@nMPs) {
    Col <- 'MP'
  } else {
    Col <- 'Class'
  }

  nPMs <- length(PMlist)
  if (nPMs %% 2 != 0) {
    message("Odd number of PMs. Recycling first PM")
    PMlist <- c(PMlist, PMlist[1])
    nPMs <- length(PMlist)
  }
  if (length(Lims) < nPMs) {
    message("Recycling limits")
    Lims <- rep(Lims,10)[1:nPMs]
  }
  if (length(Lims) > nPMs) {
    Lims <- Lims[1:nPMs]
  }

  runPM <- vector("list", length(PMlist))
  for (X in 1:length(PMlist)) {
    ref <- Refs[[PMlist[X]]]
    yrs <- Yrs[[PMlist[X]]]
    if (is.null(ref)) {
      if (is.null(yrs)) {
        runPM[[X]] <- eval(call(PMlist[X], MSEobj))
      } else {
        runPM[[X]] <- eval(call(PMlist[X], MSEobj, Yrs=yrs))
      }

    } else {
      if (is.null(yrs)) {
        runPM[[X]] <- eval(call(PMlist[X], MSEobj, Ref=ref))
      } else {
        runPM[[X]] <- eval(call(PMlist[X], MSEobj, Ref=ref, Yrs=yrs))
      }
    }

  }
  nplots <- nPMs/2
  n.col <- ceiling(sqrt(nplots))
  n.row <- ceiling(nplots/n.col)

  m <- matrix(1:(n.col*n.row), ncol=n.col, nrow=n.row, byrow=FALSE)
  xmin <- xmax <- ymin <- ymax <- x <- y <- Class <- label <- fontface <- NULL
  plots <- listout <- list()

  xInd <- seq(1, by=2, length.out=nplots)
  yInd <- xInd + 1

  if (!(is.null(Title))) Title <- rep(Title, nplots)[1:nplots]

  for (pp in 1:nplots) {
    yPM <- PMlist[yInd[pp]]
    yvals <- runPM[[match(yPM, PMlist)]]@Mean
    ycap <-  runPM[[match(yPM, PMlist)]]@Caption
    yname <-  runPM[[match(yPM, PMlist)]]@Name
    yline <- Lims[match(yPM, PMlist)]

    xPM <- PMlist[xInd[pp]]
    xvals <- runPM[[match(xPM, PMlist)]]@Mean
    xcap <-  runPM[[match(xPM, PMlist)]]@Caption
    xname <-  runPM[[match(xPM, PMlist)]]@Name
    xline <- Lims[match(xPM, PMlist)]

    xlim <- c(0, max(max(xvals, 1)))
    ylim <- c(0, max(max(yvals, 1)))

    xrect <- data.frame(xmin=0, xmax=xline, ymin=0, ymax=max(ylim))
    yrect <- data.frame(xmin=0, xmax=max(xlim), ymin=0, ymax=yline)

    if(legend) {
      MPType <- MPtype(MSEobj@MPs)
      Class <- MPType[match(MSEobj@MPs, MPType[,1]),2]
    } else {
      Class <- rep('', MSEobj@nMPs)
    }

    if (methods::is(MSEobj,'MSE')) {
      labels <- MSEobj@MPs
      if (methods::is(Labels,"list")) {
        repnames <- names(Labels)
        invalid <- repnames[!repnames %in% labels]
        if (length(invalid >0)) {
          warning("Labels: ", paste(invalid, collapse=", "), " are not MPs in MSE")
          Labels[invalid] <- NULL
          repnames <- names(Labels)
        }
        labels[labels %in% repnames] <- Labels %>% unlist()
      }
    } else {
      labels <- runPM[[1]]@MPs

    }


    df <- data.frame(x=xvals, y=yvals, label=labels, Class=Class,
                     pass=xvals>xline & yvals>yline, fontface="plain", xPM=xPM, yPM=yPM)
    df$fontface <- as.character(df$fontface)
    df$fontface[!df$pass] <- "italic"
    df$fontface <- factor(df$fontface)
    listout[[pp]] <- df

    if (Satisficed) {
      xlim <- c(xline, 1)
      ylim <- c(yline, 1)
      plots[[pp]] <- ggplot2::ggplot()
    } else {
      plots[[pp]] <- ggplot2::ggplot() +
        ggplot2::geom_rect(data=xrect, ggplot2::aes(xmin=xmin, xmax=xmax, ymin=ymin, ymax=ymax), fill=fill, alpha=alpha) +
        ggplot2::geom_rect(data=yrect, ggplot2::aes(xmin=xmin, xmax=xmax, ymin=ymin, ymax=ymax), fill=fill, alpha=alpha)
    }

    if (Col == "Class") {
      plots[[pp]] <-  plots[[pp]] +
        ggplot2::geom_point(data=df, ggplot2::aes(x, y, shape=Class, color=Class), size=point.size, na.rm=TRUE)
      if (!is.null(lab.size))
        plots[[pp]] <-  plots[[pp]] +
          ggrepel::geom_text_repel(data=df, ggplot2::aes(x, y, color=Class, label=label,
                                                         fontface = fontface),
                                   show.legend=FALSE, size=lab.size, na.rm=TRUE)
    } else if (Col == "MP") {
      plots[[pp]] <-  plots[[pp]] +
        ggplot2::geom_point(data=df, ggplot2::aes(x, y, shape=Class, color=label), size=point.size, na.rm=TRUE)
      if (!is.null(lab.size))
        plots[[pp]] <-  plots[[pp]] +
          ggrepel::geom_text_repel(data=df, ggplot2::aes(x, y, color=label, label=label,
                                                         fontface = fontface),
                                   show.legend=FALSE, size=lab.size, na.rm=TRUE)
    }

    plots[[pp]] <-  plots[[pp]] +
      ggplot2::xlab(xcap) + ggplot2::ylab(ycap) +
      ggplot2::xlim(xlim) + ggplot2::ylim(ylim) +
      ggplot2::theme_classic() +
      ggplot2::theme(axis.title = ggplot2::element_text(size=axis.title.size),
                     axis.text = ggplot2::element_text(size=axis.text.size),
                     legend.text=ggplot2::element_text(size=legend.title.size),
                     legend.title = ggplot2::element_text(size=legend.title.size)) +
      ggplot2::labs(shape= "MP Type", color="MP Type")
    if (Col == "Class") {
      plots[[pp]] <-  plots[[pp]] +  ggplot2::scale_colour_manual(values=cols)
    } else if (Col == "MP") {
      plots[[pp]] <-  plots[[pp]] +  ggplot2::scale_colour_manual(values=cols) +  ggplot2::guides(color='none')
    }

    if (!is.null(Title))
      plots[[pp]] <-  plots[[pp]] + ggplot2::labs(title=Title[pp])

    if (legend==FALSE)
      plots[[pp]] <-  plots[[pp]] + ggplot2::theme(legend.position="none")

  }

  out <- do.call("rbind", listout)
  tab <- table(out$label, out$pass)
  passall <- rownames(tab)[tab[,ncol(tab)] == nplots]
  if (methods::is(MSEobj,'MSE')) {
    Results <- summary(MSEobj, PMlist, silent=TRUE, Refs=Refs)
    Results$Satisificed <- FALSE
    Results$Satisificed[match(passall, Results$MP)] <- TRUE
    Results <- Results[,unique(colnames(Results))]
  } else {
    Results <- 'Summary table of results only available for objects of class `MSE`'
  }

  out <- list(Results=Results, Plots=plots)
  if (Show == "plots") {
    join_plots(plots, n.col, n.row,  position = position, legend=legend)
  } else if (Show == "table") {
    print(Results)
  } else if (Show == "none") {
    return(invisible(out))
  } else {
    join_plots(plots, n.col, n.row,  position = position, legend=legend)
    if (methods::is(MSEobj,'MSE')) print(Results)
  }
  invisible(out)
}


#' @describeIn TradePlot A trade-off plot showing probabilities that:
#' \itemize{
#' \item not overfishing (PNOF) against long-term yield is > 50\% of reference yield (LTY)
#' \item spawning biomass is below BMSY (P100) against LTY
#' \item spawning biomass is below 0.5BMSY (P50) against LTY
#' \item spawning biomass is below 0.1BMSY (P10) against LTY
#' }
#'
#' @export
Tplot <- function(MSEobj, Lims=c(0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5), ...) {
  if (!methods::is(Lims,"numeric")) stop("Second argument must be numeric")
  TradePlot(MSEobj, Lims=Lims, PMlist=list("PNOF", "LTY", "P100", "LTY", "P50", "LTY", "P10", "LTY"),  ...)
}

#' @describeIn TradePlot A trade-off plot showing probabilities that:
#' \itemize{
#' \item short-term yield is > 50\% of reference yield(STY) against long-term yield is > 50\% of reference yield (LTY)
#' \item spawning biomass is below 0.1BMSY (P10) against average annual variability in yield is < 20\% (AAVY)
#' }
#'
#' @export
Tplot2 <- function(MSEobj, Lims=c(0.2, 0.2, 0.8, 0.8), ...) {
  if (!methods::is(Lims,"numeric"))stop("Second argument must be numeric")
  TradePlot(MSEobj, Lims=Lims, PMlist=list("STY", "LTY", "P10", "AAVY"), ...)
}

#' @describeIn TradePlot A trade-off plot showing probabilities that:
#' \itemize{
#' \item not overfishing (PNOF) against long-term yield is > 50\% of reference yield (LTY)
#' \item spawning biomass is below 0.1BMSY (P10) against average annual variability in yield is < 20\% (AAVY)
#' }
#'
#' @export
Tplot3 <- function(MSEobj, Lims=c(0.5, 0.5, 0.8, 0.5), ...) {
  if (!methods::is(Lims,"numeric")) stop("Second argument must be numeric")
  TradePlot(MSEobj, Lims=Lims, PMlist=list("PNOF", "LTY", "P50", "AAVY"), ...)
}



#' @describeIn TradePlot A trade-off plot developed for NOAA showing probabilities that:
#' \itemize{
#' \item not overfishing (PNOF) against long-term yield is > 50\% of reference yield (LTY)
#' \item spawning biomass is below 0.5BMSY (P50) against average annual variability in yield is < 15\% (AAVY)
#' }
#'
#' @export
NOAA_plot2 <- function(MSEobj) {
  TradePlot(MSEobj, Lims=c(0.5, 0, 0.8, 0.5), PMlist=list("PNOF", "LTY", "P50", "AAVY"), Refs=list(AAVY=0.15))
}



#' Plot the median biomass and yield relative to last historical year
#'
#' Compare median biomass and yield in first year and last 5 years of
#' projection
#'
#' @param MSEobj An object of class MSE
#' @param MPs Optional vector of MPs to plot
#' @param lastYrs Numeric. Last number of years to summarize results.
#' @param point.size Size of the points
#' @param lab.size Size of labels
#' @param axis.title.size Axis title size
#' @param axis.text.size  Axis text size
#' @param legend.title.size Legend title size
#'
#' @export
#'
#' @examples
#' \dontrun{
#' MSE <- runMSE()
#' Cplot(MSE)
#' }
Cplot <- function(MSEobj, MPs = NA, lastYrs = 5,
                  point.size=2,
                  lab.size=4,
                  axis.title.size=12,
                  axis.text.size=10,
                  legend.title.size=12) {
  if (!all(is.na(MPs))) MSEobj <- Sub(MSEobj, MPs = MPs)

  if (!requireNamespace("ggrepel", quietly = TRUE)) {
    stop("Package \"ggrepel\" needed for this function to work. Please install it.",
         call. = FALSE)
  }

  mp <- Catch <- Biomass <- mB <- mC <- NULL # cran check hacks
  nsim <- MSEobj@nsim
  nMPs <- MSEobj@nMPs
  MPs <- MSEobj@MPs
  nyears <- MSEobj@nyears
  proyears <- MSEobj@proyears
  RefYd <- MSEobj@OM$RefY

  MPType <- MPtype(MSEobj@MPs)
  Class <- MPType[match(MSEobj@MPs, MPType[,1]),2]

  pastC <- MSEobj@CB_hist/RefYd # relative catch in last historical year
  # pastC <- apply(MSEobj@CB_hist[, , , , drop = FALSE], c(1, 3), sum, na.rm = TRUE)/RefYd # relative catch in last historical year
  temp <- aperm( replicate(nMPs, pastC), c(1, 3, 2))

  lastYr <- temp[, , nyears, drop = FALSE]
  Yield <- abind::abind(lastYr, MSEobj@Catch[, , , drop = FALSE]/RefYd, along = 3) #

  ny <- MSEobj@proyears + 1
  relYield <- Yield[, , , drop = FALSE]/Yield[, , rep(1, ny), drop = FALSE] # catch relative to last historical year
  relYield <- relYield[,,(proyears - lastYrs + 1):proyears]

  # Biomass
  bio <- MSEobj@SB_SBMSY[,,(proyears - lastYrs + 1):proyears] # biomass in lastyrs
  histSSB <- MSEobj@SSB_hist
  # histSSB <- apply(MSEobj@SSB_hist[, , , , drop = FALSE], c(1, 3), sum, na.rm = TRUE)
  relSSB <- histSSB[,nyears]/ MSEobj@OM$SSBMSY # SSB/SSBmsy in last historical year
  temp <- array(replicate(nMPs, relSSB), dim=dim(bio)) # array with biomass in last projection year

  relbio <- bio/temp # biomass relative to biomass at start of projections

  dimnames(relbio) <- list(1:nsim, MPs, 1:lastYrs)
  Bdf <- as.data.frame.table(relbio)
  names(Bdf) <- c("sim", "mp", "yr", 'Biomass')

  dimnames(relYield) <- list(1:nsim, MPs, 1:lastYrs)
  Cdf <- as.data.frame.table(relYield)
  names(Cdf) <- c("sim", "mp", "yr", 'Catch')

  DF <- dplyr::left_join(Cdf, Bdf,by = c("sim", "mp", "yr"))
  DF <- DF %>% dplyr::group_by(mp) %>% dplyr::summarize(mC=median(Catch),
                                    upC=quantile(Catch, 0.95),
                                    lowC=quantile(Catch, 0.05),
                                    mB=median(Biomass),
                                    upB=quantile(Biomass, 0.95),
                                    lowB=quantile(Biomass, 0.05),
                                    .groups='keep')
  DF$class <- Class


  p1 <- ggplot2::ggplot(DF, ggplot2::aes(x=mB, y=mC, color=class, shape=class)) +
    ggplot2::geom_point() +
    ggplot2::expand_limits(x=0, y=0) +
    ggplot2::geom_vline(xintercept = 1, color="gray") +
    ggplot2::geom_hline(yintercept = 1, color="gray") +
    ggplot2::theme_classic() +
    ggplot2::theme(axis.title = ggplot2::element_text(size=axis.title.size),
                   axis.text = ggplot2::element_text(size=axis.text.size),
                   legend.text=ggplot2::element_text(size=legend.title.size),
                   legend.title = ggplot2::element_text(size=legend.title.size)) +
    ggrepel::geom_text_repel(ggplot2::aes(label=mp), show.legend=FALSE) +
    ggplot2::labs(x=paste("Median Spawning Biomass (last", lastYrs,
                 "years)\n relative to current"),
         y=paste("Median Yield (last", lastYrs, "years)\n relative to current"),
         shape= "MP Type", color="MP Type")

  print(p1)

}


# #' Value of Information Plot using PM functions
# #'
# #' This VOI plot shows the value of information for a single MP and uses the `PM`
# #' functions.
# #'
# #' @param MSE An object of class `MSE`
# #' @param MP The name or number of MP to plot. Character or numeric.
# #' @param type Character. Type of VOI plot - "Obs" or "OM"
# #' @param PM Name of a `PM` method to plot on the y-axis
# #' @param n The maximum number of variables to plot.
# #' @param axis.title.size Size of axis title
# #' @param axis.text.size Size of axis text
# #' @param legend.title.size Size of legend text
# #' @param include.leg Logical. Include the legend?
# #'
# #' @author A. Hordyk
# #' @export
# #'
# #' @examples
# #' \dontrun{
# #' MSE <- runMSE()
# #' VOIplot2(MSE)
# #'
# #' VOIplot2(MSE, "OM")
# #'
# #' VOIplot2(MSE, PM='P100')
# #'
# #' }
# #'
# VOIplot2 <- function(MSE, MP=1, type=c("Obs", "OM"), PM="Yield", n=5,
#                      axis.title.size=12,
#                      axis.text.size=10,
#                      legend.title.size=10, include.leg=TRUE) {
#   if (class(MSE) !="MSE") stop("Object must be class MSE", call.=FALSE)
#   if (length(MP)>1) stop("MP must be length 1", call.=FALSE)
#   if (length(PM)>1) stop("PM must be length 1", call.=FALSE)
#   if (class(PM) != "character") stop("PM must be character", call.=FALSE)
#   if (!PM %in% avail('PM')) stop('PM is not an available `PM` function', call.=FALSE)
#
#   # cran check
#   key <- data <- fit <- var <- .fitted <- desc <- value <- NULL
#   MSEobj <- Sub(MSE, MPs=MP)
#
#   if (!requireNamespace("broom", quietly = TRUE)) {
#     stop("Package \"broom\" needed for this function to work. Please install it.",
#          call. = FALSE)
#   }
#   if (!requireNamespace("purrr", quietly = TRUE)) {
#     stop("Package \"purrr\" needed for this function to work. Please install it.",
#          call. = FALSE)
#   }
#   if (!requireNamespace("tidyr", quietly = TRUE)) {
#     stop("Package \"tidyr\" needed for this function to work. Please install it.",
#          call. = FALSE)
#   }
#
#   type <- match.arg(type)
#
#   if (type =="OM") {
#     Ptype <- OM_desc # OM_desc <- MSEtool:::OM_desc
#     Xvals <- MSEobj@OM
#   } else {
#     Ptype <- Obs_desc  # Obs_desc <- MSEtool:::Obs_desc
#     Xvals <- MSEobj@Obs
#     reqdat <- Required(MSEobj@MPs)[,2]
#     reqdat <- trimws(unlist(strsplit(reqdat, ",")))
#
#     for (rr in 1:nrow(Ptype)) {
#       tt <- any(trimws(unlist(strsplit(Ptype$DataSlot[rr], ","))) %in% reqdat)
#       Ptype$VOI_include[rr] <- tt
#     }
#   }
#
#   Ptype$VOI_include[is.na(Ptype$VOI_include)] <- TRUE
#   Ptype$Const <- round(apply(Xvals, 2, mean),4) == round(apply(Xvals, 2, min),4)
#   Ptype$VOI_include[Ptype$Const] <- FALSE # drop any variables that are constant across simulations
#
#   pm <- get(PM)(MSEobj)
#   Yval <- apply(pm@Stat, 1, mean)
#   rng <- quantile(Yval, c(0.025, 0.975))
#   ind <- which(Yval > rng[1] & Yval < rng[2]) # filter out middle 95%
#   Yval <- Yval[ind]
#   Xvals <- Xvals[,Ptype$VOI_include, drop=FALSE]
#   if (sum(Ptype$VOI_include) == 0) stop("No Observations for this MP", call.=FALSE)
#   Xvals <- Xvals[ind,, drop=FALSE]
#   Xdf <- tidyr::gather(Xvals)
#
#   Yval <- data.frame(Yval=rep(Yval, ncol(Xvals)))
#   df <- dplyr::bind_cols(Xdf, Yval)
#
#   ## Fit a loess smoother  ##
#   span <- 0.75; degree <- 2
#   # l.mod_old <- df %>% tidyr::nest_legacy(-key) %>%
#   #   dplyr::mutate(fit = purrr::map(data, ~ loess(Yval ~ value, span=span, degree=degree, .))) %>%
#   #   tidyr::unnest_legacy(purrr::map2(fit, data, broom::augment))
#
#   l.mod <- df %>% tidyr::nest(.,data=c('value', 'Yval')) %>%
#     dplyr::mutate(fit = purrr::map(data, ~ loess(Yval ~ value, span=span, degree=degree, .)))
#   l.mod2 <- purrr::map2(l.mod$fit, l.mod$data, broom::augment) %>% do.call("rbind",.)
#   l.mod <- left_join(df, l.mod2,  by=c("value", "Yval"))
#
#   # Calculate variance of fitted line and order by descending variance
#   lev.ord <- l.mod %>% group_by(key) %>%
#     dplyr::summarize(var=var(.fitted)) %>%
#     dplyr::arrange(desc(var))
#
#   df <- dplyr::left_join(df, lev.ord, by="key")
#   df$key <- factor(df$key,  levels=lev.ord$key, ordered = TRUE)
#   levels(df$key) <- Ptype$Short_Name[match(levels(df$key), Ptype$Variable)]
#
#   l.mod$key <- factor(l.mod$key,  levels=lev.ord$key, ordered = TRUE)
#   levels(l.mod$key) <- Ptype$Short_Name[match(levels(l.mod$key), Ptype$Variable)]
#
#   sdf <- df %>% dplyr::select(key, var) %>% dplyr::distinct() %>%  dplyr::top_n(n, var) %>% select(key)
#   pdf <- df %>% filter(key %in% sdf$key)
#   l.mod2 <- l.mod %>% filter(key %in% sdf$key)
#
#   title <- paste0(MSEobj@MPs, ' - ',  type, ' Parameters (top ', n, ")")
#   nrow <- ceiling(n/5)
#
#
#   p1 <- ggplot2::ggplot(pdf, ggplot2::aes(x=value, y=Yval, color=var)) +
#     ggplot2::facet_wrap(~key, scales="free_x", nrow=nrow, ncol=5) +
#     ggplot2::geom_point() + ggplot2::theme_classic() +
#     ggplot2::geom_line(data=l.mod2, ggplot2::aes(x=value, y=.fitted, color=NULL), size=1.25) +
#     ggplot2::labs(title=title, y=pm@Name, color='Variance', x="Parameter Value") +
#     ggplot2::expand_limits(y=0) +
#     ggplot2::theme(axis.title = ggplot2::element_text(size=axis.title.size),
#                    axis.text = ggplot2::element_text(size=axis.text.size),
#                    legend.text=ggplot2::element_text(size=legend.title.size),
#                    legend.title = ggplot2::element_text(size=legend.title.size))
#
#
#   if (!include.leg) p1 <- p1 + ggplot2::guides(colour=FALSE)
#
#   p1
#
# }
#
#
#
#

