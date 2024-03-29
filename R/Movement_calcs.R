
#' Calculates movement matrices from user inputs
#'
#' A wrapper function for \link{makemov} used to generate movement matrices for the operating model.
#' Calculates a movement matrix from user-specified unfished stock biomass fraction in each area and probability of
#' staying in the area in each time step.
#' @param OM Operating model, an object of class \linkS4class{OM}.
#' @param dist A vector of fractions of unfished stock in each area. The length of this vector will determine the
#' number of areas (\code{nareas}) in the OM.
#' @param prob Mean probability of staying across all areas (single value) or a vector of the probability of
#' individuals staying in each area (same length as dist).
#' @param distE Logit (normal) St.Dev error for sampling stock fractions from the fracs vector
#' @param probE Logit (normal) St.Dev error for sampling desired probability of staying either by area
#' (prob is same length as dist) or the mean probability of staying (prob is a single number).
#' @param prob2 Optional vector as long as prob and dist. Upper bounds on uniform sampling of
#' probability of staying, lower bound is prob.
#' @param figure Logical to indicate if the movement matrix will be plotted (mean values and range
#' across \code{OM@@nsim} simulations.)
#' @return The operating model \code{OM} with movement parameters in slot \code{cpars}.
#' The \code{mov} array is of dimension \code{nsim}, \code{maxage}, \code{nareas}, \code{nareas}.
#' @note Array \code{mov} is age-specific, but currently the movement generated by \code{simmov} is
#' independent of age.
#' @author T. Carruthers and Q. Huynh
#' @export
#' @examples
#' \dontrun{
#' movOM_5areas <- simmov(testOM, dist = c(0.01,0.1,0.2,0.3,0.39), prob = c(0.1,0.6,0.6,0.7,0.9))
#' movOM_5areas@@cpars$mov[1, 1, , ] # sim 1, age 1, movement from areas in column i to areas in row j
#' plot_mov(movOM_5areas@@cpars$mov)
#' plot_mov(movOM_5areas@@cpars$mov, type = "all")
#'
#' }
#' @describeIn simmov Estimation function for creating movement matrix.
simmov <- function(OM, dist = c(0.1, 0.2, 0.3, 0.4), prob = 0.5, distE = 0.1, probE = 0.1, prob2 = NA, figure = TRUE) {

  nareas <- length(dist)
  if(nareas < 2) stop("Error: nareas, i.e., length(dist), is less than 2.")
  nsim <- OM@nsim
  maxage <- OM@maxage

  dist_s <- rnorm(nareas*nsim, log(dist), distE) %>% matrix(nrow = nareas) %>% t() %>% ilogitm()

  if(length(prob) == 1) {
    prob_s <- rnorm(nsim, logit(prob), probE) %>% matrix(nrow = nsim) %>% ilogit()
  } else if(length(prob) == length(dist) && is.na(prob2)) {
    prob_s <- rnorm(nareas*nsim, logit(prob), probE) %>% matrix(nrow = nareas) %>% t() %>% ilogit()
  } else if(length(prob) == length(dist) && length(prob) == length(prob2)) {
    prob_s <- runif(nareas*nsim, prob, prob2) %>% matrix(nrow = nareas) %>% t()
  } else{
    stop("Error: either prob wasn't of length 1, or prob wasn't of length dist or prob 2 wasn't the same length as prob and dist.
            You have three options:
            (1) provide one value for prob which represents mean probability of staying across all areas sampled for each simulation with probE logit error
            (2) provide nareas values of prob which represent probability of staying across all areas sampled for each simulation with probE logit error
            (3) provide nareas values of prob and prob2 which are the upper and lower bounds for sampling uniform probability of staying for each area")
  }

  movt <- lapply(1:nsim, function(i) makemov(fracs = dist_s[i, ], prob = prob_s[i, ]) %>% array(c(nareas, nareas, maxage + 1)))
  mov <- simplify2array(movt) %>% aperm(c(4, 3, 1, 2))

  OM@cpars$mov <- mov
  if(figure) plot_mov(mov, type = "matrix")

  return(OM)
}

opt_mov <- function(x, fracs, prob, nareas) {
  grav_out <- grav(log_visc = x[1:length(prob)], log_grav = x[(length(prob)+1):length(x)],
                   fracs = fracs, nareas = nareas)

  nll_dist <- dnorm(log(grav_out$idist), log(fracs), 0.1, TRUE)
  if(length(prob) == 1) {
    nll_stay <- dnorm(log(grav_out$psum), log(prob), 0.1, TRUE)
  } else {
    nll_stay <- dnorm(log(diag(grav_out$mov)), log(prob), 0.1, TRUE)
  }
  nll <- c(nll_dist, nll_stay) %>% sum()
  return(-nll)
}

#' Calculates movement matrices from user inputs for fraction in each area (fracs) and probability of staying in areas (prob)
#'
#' @description A function for calculating a movement matrix from user specified unfished stock biomass fraction in each area.
#' Used by \link{simmov} to generate movement matrices for an operating model.
#' @param fracs A vector nareas long of fractions of unfished stock biomass in each area
#' @param prob A vector of the probability of individuals staying in each area or a single value for the mean probability of staying among all areas
#' @author T. Carruthers
#' @export
#' @seealso \link{simmov}
makemov <- function(fracs = c(0.1, 0.2, 0.3, 0.4), prob = c(0.5, 0.8, 0.9, 0.95)) {

  nareas <- length(fracs)
  nprob <- length(prob)

  opt <- stats::nlminb(rep(0, nprob + nareas - 1), opt_mov, fracs = fracs, prob = prob, nareas = nareas,
                control = list(iter.max = 5e3, eval.max = 1e4))
  mov <- grav(log_visc = opt$par[1:length(prob)], log_grav = opt$par[(length(prob)+1):length(opt$par)],
              fracs = fracs, nareas = nareas)$mov
  return(mov)
}


# #' Checks the TMB equations again estimated movement matrices and also checks fit
# #'
# #' @description A function for calculating a movement matrix from user specified unfished stock biomass fraction in each area
# #' @param obj A list object arising from MakeADFun from either grav.h or grav_Pbyarea.h
# #' @author T. Carruthers
# #' @export validateTMB
validateTMB <- function(obj) {

  log_grav<-obj$report()$log_grav
  log_visc<-obj$report()$log_visc
  nareas<-length(log_grav)+1

  grav<-array(0,c(nareas,nareas))
  grav[,2:nareas]<-rep(log_grav,each=nareas)
  grav[cbind(1:nareas,1:nareas)]<-grav[cbind(1:nareas,1:nareas)]+log_visc

  mov<-exp(grav)/apply(exp(grav),1,sum)

  idist<-rep(1/nareas,nareas)
  for(i in 1:50)idist<-apply(idist*mov,2,sum)

  print(obj$report()$idist)
  print(idist)
  print(obj$report()$fracs)

  print(obj$report()$mov)
  print(mov)

}

# Simmov2   =========================================================================================================

#' Calculates movement matrices from user specified distribution among other areas
#'
#' A wrapper function for \link{makemov2} used to generate movement matrices for the operating model.
#' Calculates a movement matrix from user-specified relative movement to other areas and probability of
#' staying in the area in each time step.
#' @param OM Operating model, an object of class \linkS4class{OM}.
#' @param dist A vector of fractions of unfished stock in each area. The length of this vector will determine the
#' number of areas (\code{nareas}) in the OM.
#' @param distE Logit (normal) St.Dev error for sampling desired fraction in each area
#' @param frac_other A matrix (nareas rows from, nareas columns to) of relative fractions moving to other areas (the positive diagonal (staying) is unspecified). 
#' @param frac_otherE Logit (normal) St.Dev error for sampling desired fraction moving to other areas. 
#' @param prob the mean probability of staying in the same area among all areas
#' @param probE Logit (normal) St.Dev error for sampling desired probability of staying in each area
#' @param figure Logical to indicate if the movement matrix will be plotted (mean values and range
#' across \code{OM@@nsim} simulations.)
#' @return The operating model \code{OM} with movement parameters in slot \code{cpars}.
#' The \code{mov} array is of dimension \code{nsim}, \code{maxage}, \code{nareas}, \code{nareas}.
#' @note Array \code{mov} is age-specific, but currently the movement generated by \code{simmov} is
#' independent of age.
#' @author T. Carruthers and Q. Huynh
#' @export
#' @examples
#' \dontrun{
#' movOM_3areas <- simmov2(testOM, frac_other = matrix(c(NA,2,1, 2,NA,1, 1,2,NA),
#' nrow=3, byrow=T), frac_otherE = 0.01, prob = 0.8, probE = 0.3)
#' # sim 1, age 1, movement from areas in column i to areas in row j
#' movOM_3areas@@cpars$mov[1, 1, , ] 
#' plot_mov(movOM_3areas@@cpars$mov)
#' plot_mov(movOM_3areas@@cpars$mov, type = "all")
#'
#' }
#' @describeIn simmov2 Estimation function for creating movement matrix.
simmov2 <- function(OM,dist=c(0.05,0.6,0.35), distE = 0.01,
                    frac_other = matrix(c(NA,2,1, 3,NA,1, 1,4,NA),nrow=3, byrow=T),
                    frac_otherE = 0.01, prob = 0.8, probE = 1, 
                    figure = TRUE) {
  
  nareas <- length(dist)
  if(nareas < 2) stop("Error: nareas, i.e., length(dist), is less than 2.")
  nsim <- OM@nsim
  maxage <- OM@maxage
  
  dist_s <- rnorm(nareas*nsim, log(dist), distE) %>% matrix(nrow = nareas) %>% t() %>% ilogitm()
  prob_s <- rnorm(nsim, logit(prob), probE) %>% matrix(nrow = nsim) %>% ilogit()
  suppressWarnings({ frac_other_s = array(exp(rnorm(nsim*nareas*nareas,log(frac_other),frac_otherE)),c(nareas,nareas,nsim))})
  
  movt <- lapply(1:nsim, function(i) makemov2(dist = dist_s[i, ], prob = prob_s[i, ], probE=probE, frac_other = frac_other_s[,,i]) %>% array(c(nareas, nareas, maxage + 1)))
  mov <- simplify2array(movt) %>% aperm(c(4, 3, 1, 2))
  
  OM@cpars$mov <- mov
  if(figure) plot_mov(mov, type = "matrix")
  
  return(OM)
}

markov_frac = function(logit_probs,frac_other){
  probs = ilogit(logit_probs)
  left = 1-probs
  mov = frac_other/apply(frac_other,1,sum,na.rm=T)*left
  diag(mov) = probs
  # all(apply(mov,1,sum)==1) # check
  mov
}

opt_mov2 <- function(x, dist, prob, probE, frac_other, nits = 50) {
  logit_probs = x
  mov = markov_frac(logit_probs,frac_other)
  outdist = CalcAsymptoticDist(mov,dist,nits=nits,plot=F)
  nll_dist <- dnorm(log(outdist), log(dist), 0.1, TRUE)
  nll_stay <- dnorm(logit_probs, logit(prob), probE, TRUE)
  nll <- c(nll_dist, nll_stay) %>% sum()
  return(-nll)
}

#' Calculates movement matrices from user inputs for fraction in each area (fracs) the relative fraction moving to other areas, plus a mean probability of staying in any given area. 
#'
#' @description A function for calculating a movement matrix from user specified distribution among areas (v) and relative movement to other areas (solves for positive diagonal - vector of prob staying).
#' Used by \link{simmov2} to generate movement matrices for an operating model. There must be a prior on the positive diagonal of the movement matrix or these will tend to 1
#' and hence perfectly satisfy the requirement V = MV. 
#' @param dist A vector nareas long of fractions of unfished stock biomass in each area
#' @param prob A vector of the probability of individuals staying in each area or a single value for the mean probability of staying among all areas
#' @param probE The logit CV associated with prob (used as a penalty when optimizing for diagonal)
#' @param frac_other A matrix nareas x nareas that specifies the relative fraction moving from one area to the others. The positive diagonal is unspecified. 
#' @param plot Should the convergence to a stable distribution be plotted?
#' @author T. Carruthers
#' @export
#' @seealso \link{simmov2}
makemov2 <- function(dist = c(0.05, 0.6, 0.35), prob = 0.5,
                     probE = 1, 
                     frac_other = matrix(c(NA,2,1, 2,NA,1, 1,2,NA),nrow=3, byrow=T),
                     plot=F){
  nareas <- length(dist)
  opt <- stats::nlminb(rep(0,nareas), opt_mov2, dist = dist, prob = prob, probE = probE, frac_other = frac_other, 
                       control = list(iter.max = 5e3, eval.max = 1e4))
  
  mov = markov_frac(opt$par, frac_other)
  if(plot)CalcAsymptoticDist(mov,dist,plot=T)
  return(mov)
}

#' Calculates the asymptotic distribution from an initial distribution vector (V) and a markov movement matrix (M) (rows sum to 1) 
#'
#' @description Calculates the asymptotic distribution from an initial distribution vector (V) and a markov movement matrix (M) (rows sum to 1).  
#' @param M A square markov movement matrix M of nareas rows and nareas columns (rows sum to 1) 
#' @param V An optional vector nareas long of initial fractions by area (if unspecified the calculation will start from a uniform distribution)
#' @param nits An integer number of iterations for multiplying V by M to get the asymptotic distribution (~50 is usually enough)
#' @param plot Should the convergence to a stable distribution be plotted?
#' @author T. Carruthers
#' @export
#' @seealso \link{simmov2}
#' @keywords internal
CalcAsymptoticDist = function(M,V=NULL,nits=50,plot=F){
  
  if(is.null(V)) V = rep(1/dim(M)[1],dim(M)[1])
  if(!all(length(V)==dim(M))) stop("Error in CalcAsymptoticDist(): the length of the distribution vector V is not the same as the dimensions of the square movement matrix M")
  strV = V
  tol=rep(NA,nits)
  for(i in 1:nits){
    temp = V%*%M
    tol[i] = mean(abs(temp-V))
    V = temp
  }
  if(plot){
    par(mfrow=c(1,2),mai=c(0.3,0.3,0.01,0.01),omi=c(0.05,0.05,0.3,0.05))
    plot(tol,pch=19,col='blue'); lines(tol,col ="blue");grid()
    plot(1:length(V),strV,col='#0000ff90',pch=1,lwd=2,cex=1.3,ylim=c(0,max(V,strV)));grid()
    points(1:length(V),V,col="#ff000090",lwd=2,pch=3,cex=1.3)
    legend('topright',legend=c("Specified","Achieved"),text.col=c("red","blue"),bty='n')
  }
  V
}


#' @param mov A four-dimensional array of dimension \code{c(nsim, maxage, nareas, nareas)} or a five-dimensional
#' array of dimension \code{c(nsim, maxage, nareas, nareas, nyears + proyears)} specifying movement 
#' in the operating model.
#' @param age An age from 0 to maxage for the movement-at-age matrix figure when \code{type = "matrix"}.
#' @param type Whether to plot a movement matrix for a single age (\code{"matrix"}) or the
#' full movement versus age figure (\code{"all"})
#' @param year If \code{mov} is a 5-dimensional array, the year (from 1 to nyears + proyears) for which 
#' to plot movement.
#' @param qval The quantile to plot or report the range of values among simulations.
#' @describeIn simmov Plotting function.
#' @export
plot_mov <- function(mov, age = 1, type = c("matrix", "all"), year = 1, qval = 0.9) {
  type <- match.arg(type)
  nsim <- dim(mov)[1]
  maxage <- dim(mov)[2] - 1
  nareas <- dim(mov)[3]
  old_par <- par(no.readonly = TRUE)
  on.exit(par(old_par))
  
  if(length(dim(mov)) == 5) mov <- mov[, , , , year]

  if(type == "matrix") {
    mov_at_age <- mov[ , age + 1, , ] # dimension nsim, narea, narea
    q_mov <- apply(mov_at_age, c(2, 3), quantile, probs = c(0.5 * (1 - qval), 0.5, qval + 0.5 * (1 - qval)))
    
    plot(NULL, NULL, xlab = "Area (from)", ylab = "Area (to)", 
         xaxp = c(1, nareas, nareas - 1), yaxp = c(1, nareas, nareas - 1),
         xaxs = "i", yaxs = "i",
         xlim = c(0.5, nareas + 0.5), ylim = c(0.5, nareas + 0.5))
    abline(h = 1.5:(nareas - 0.5), v = 1.5:(nareas - 0.5))
    
    if(identical(q_mov[1, , ], q_mov[3, , ])) {
      for(i in 1:nareas) {
        for(j in 1:nareas) {
          text(i, j, labels = signif(q_mov[2, i, j], 2))
        }
      }
      title(paste0("Movement matrix at age ", age))
    } else {
      for(i in 1:nareas) {
        for(j in 1:nareas) {
          text(i, j, labels = paste0(signif(q_mov[2, i, j], 2), "\n(", signif(q_mov[1, i, j], 2), "-", signif(q_mov[3, i, j], 2), ")"))
        }
      }
      title(paste0("Movement matrix at age ", age, "\n(Median and ", 100 * qval, "% quantile over ", nsim, " simulations)"))
    }
    
    
  }

  if(type == "all") {
    q_mov <- apply(mov, 2:4, quantile, probs = c(0.5 * (1 - qval), 0.5, qval + 0.5 * (1 - qval)))

    n_plots <- nareas + 1
    ylim <- c(0, max(1, 1.1 * max(q_mov)))
    color.vec <- grDevices::rainbow(nareas)
    
    if(nareas <= 3) {
      layout_matrix <- matrix(1:4, 2, 2, byrow = TRUE) %>%
        cbind(rep(0, 2))
      layout(layout_matrix + 1, widths = c(1, 1, 0.5))
    } else {
      layout_matrix <- matrix(seq_len(ceiling(n_plots/3) * 3), ceiling(n_plots/3), 3, byrow = TRUE) %>%
        cbind(rep(0, ceiling(n_plots/3)))
      layout(layout_matrix + 1, widths = c(1, 1, 1, 0.8))
    }
    par(mar = c(2, 4, 1, 1), oma = c(4, 0, 0, 0))
    
    # Legend
    plot(1, 1, typ = "n", axes = FALSE, xlab = "", ylab = "")
    legend("left", paste("Area", 1:nareas), title = "Movement to:",
           col = color.vec, pch = 16, lty = 1, bty = "n")
    
    # Prob staying
    plot(NULL, NULL, xlim = c(0, maxage), ylim = ylim, ylab = "Probability of staying")
    abline(h = 0, col = "grey")
    lapply(1:nareas, function(i) {
      polygon(c(0:maxage, maxage:0), c(q_mov[1, , i, i], rev(q_mov[3, , i, i])), 
              col = makeTransparent(color.vec[i], 80), border = NA)
      lines(0:maxage, q_mov[2, , i, i], col = color.vec[i], lwd = 3, pch = 16)
    })
    
    # Each figure shows movement from one area to all areas
    for(j in 1:nareas) {
      plot(NULL, NULL, xlim = c(0, maxage), ylim = ylim, ylab = paste("Movement from Area", j))
      abline(h = 0, col = "grey")
      lapply(1:nareas, function(i) {
        polygon(c(0:maxage, maxage:0), c(q_mov[1, , j, i], rev(q_mov[3, , j, i])), 
                col = makeTransparent(color.vec[i], 80), border = NA)
        lines(0:maxage, q_mov[2, , j, i], col = color.vec[i], lwd = 3, pch = 16)
      })
    }
    mtext("Age", side = 1, line = 2, outer = TRUE)
    
  }

  invisible()
}

