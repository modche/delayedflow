#' Find breakpoints in DFI curve
#'
#' @description Estimates n breakpoints in the DFI curve.
#'     DFI values are compared against n+1 piecewise linear segments and the minimization of the
#'     corresponding residuals. Several parameters can be customized.
#'     If \code{q_obs} is given in daily temporal resolution then also \code{n} can be interpreted as delay in days
#'     for different contributions (default).
#'
#' @param dfi numeric, a vector with the DFI values between 1 and 0, dummy data [dfi_example] can be used.
#' @param n_bp numeric, How many breakpoints (1, 2, 3) should be estimated? Default = 2
#' @param min_gp_gap numeric, smallest interval between two breakpoints. Default = 5 (days)
#' @param filter_min numeric, `filter_min`+1 is minimum potential breakpoint estimate
#' @param filter_max numeric, `filter_max`-1 is maximum potential breakpoint estimate
#' @param of_weights vector with two elements, first is weight of the RMSE, second is weight of the MAE.
#'     Default is c(0.5, 0.5), i.e. equal weights. Sum of vector must be 1. To switch of one measure use
#'     \code{c(1, 0)} or \code{c(0,1)}. With the weighting more or less focus could be given to the upper parts
#'     of the DFI curve (i.e. when block length \code{n} for separation is between 1 and 10).
#' @param dfi_check logical, if `TRUE` DFI values are converted to be monotonically descreasing with [cummin()]
#' @param print logical, if `TRUE` best breakpoint estimates during calculation are printed (debug mode)
#' @param plotting logical, if `TRUE` the DFI curve and piecewise linear segments are plotted with \code{plot()}
#'
#' @return Returns a list.
#' \item{breakpoints}{estimates for the n breakpoints with names `bp_x`}
#' \item{bias}{value of the objective function
#'     `OF = 1/2 RMSE + 1/2 MAE`,
#'     where OF is to be minimized.}
#' \item{rel_contr}{Relative streamflow contributions between \code{filter_min}, the breakpoints and \code{filter_max},
#'     e.g. 2 breakpoints lead to 3 relative contributions, 3 breakpoints lead to 4 relative contributions.
#'     The first \code{rel_contr}-avlue is the fastest contribution to streamflow, the last \code{rel_contr}-value
#'     is the slowest contribution to streamflow.}
#' @references Stoelzle, M., Schuetz, T., Weiler, M., Stahl, K., & Tallaksen, L. M. (2020). Beyond binary baseflow separation: a delayed-flow index for multiple streamflow contributions. Hydrology and Earth System Sciences, 24(2), 849-867.
#' @export
#' @examples
#' # use dfi_example as an DFI vector with 121 values
#' find_bp(dfi_example, n_bp = 3, filter_max = 90, plotting = TRUE)
find_bp <- function(dfi,
					n_bp = 2,
					min_gp_gap = 5,
					filter_min = 0,
					filter_max = length(dfi) - 1,
					of_weights = c(0.5, 0.5),
					dfi_check = TRUE,
					print = FALSE,
					plotting = FALSE) {

	len <- length(dfi)

	if(any(is.na(dfi))) {
		stop("DFI vector has NA values.")
	}
	if(len <= filter_max) {
		stop("DFI vector is too short or reduce filter_max, i.e. length(dfi) > filter_max")
	}
	if(filter_max < filter_min + 5){
		stop("Adjust \"filter_min\" or \"filter_max\"!" )
	}
	if(min_gp_gap <= 2) {
		stop("\"min_gap\" is too small, should be 3 or larger.")
	}
	if(!n_bp %in% 1:3) {
		stop("Number of breakpoints must be 1,2 or 3")
	}

	if(sum(of_weights) != 1) {
		stop("Both weights must sum up to 1, please adjust of_weights.")
	}

	if(dfi_check) {
		dfi <- cummin(dfi)
	}

	# breakpoint grid
	len <- length(dfi)
	pot_bp <- (filter_min+1):(filter_max-1)
	bp_grid <- expand.grid(rep(list(pot_bp),n_bp))
	names(bp_grid) <- paste0("bp_",1:n_bp)

	# create breakpoint combinations
	if (n_bp == 1) bp_grid <- as.matrix(pot_bp)

	if (n_bp == 2) {
	bp_grid <- subset(bp_grid, (bp_1 < bp_2 & bp_1 + min_gp_gap <= bp_2))
	bp_grid <- as.matrix(bp_grid, rownames.force = FALSE)
	}
	if (n_bp == 3) {
	bp_grid <- subset(bp_grid, (bp_1 < bp_2 &
								bp_1 + min_gp_gap <= bp_2 &
								bp_2 < bp_3 &
								bp_2 + min_gp_gap <= bp_3 ))
	bp_grid <- as.matrix(bp_grid, rownames.force = FALSE)
	}

	# fit breakpoint model
	dummy <- 999
	best_bps <- NULL
	cat("Calculating breakpoints . . . \n 0%  ")
	for (i in 1:nrow(bp_grid)) {

		bps <- bp_grid[i,]
		fit <- approx(x = c(0,bps,len-1), dfi[c(1,bps+1,len)], xout = 0:(len-1))$y
        OF <-  rmse(fit,dfi) * of_weights[1] + mae(fit, dfi) * of_weights[2]
    	if(OF < dummy){
			if(print) cat(i,bps,OF,"\n")
			dummy <- OF
			best_fit <- fit
			result <- list(breakpoints = bps, bias = dummy )
		}

        if(i %in% floor(nrow(bp_grid) * 1:4/4)) cat(paste0(round(i/nrow(bp_grid)*100,0)),"%  ")

	}
	cat("\nBreakpoints ready . . . \n\n\n")

result$rel_contr <- -diff(c(dfi[c(1, result$breakpoints+1)], 0))

if (plotting){
	plot(0:(len-1), dfi,
		 type = "l",
		 col = "blue",
		 ylim = c(0,1),
		 ylab = "DFI",
		 xlab = "Filter width N")
	points(0:(len-1), best_fit, type = "l", col = "red")
	abline(v=result$breakpoints)
}


return(result)
}
