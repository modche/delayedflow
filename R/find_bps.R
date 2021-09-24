#' Find breakpoints in DFI curve
#'
#' @description Estimates n breakpoints in the DFI curve.
#'     DFI values are compared against n+1 piecewise linear segments and the minimization of the
#'     residuals (between linear segments and DFI curve). Several parameters can be customized.
#'     If \code{q_obs} is given in daily temporal resolution then also \code{n} can be interpreted as delay in days
#'     for different contributions (default).
#'
#' @param dfi numeric, a vector with the DFI values between 1 and 0, dummy data [dfi_example] can be used.
#' @param n_bp numeric, How many breakpoints (1, 2, 3) should be estimated (default = 2)? If \code{n_bp = 3}
#'     calculation time could be longer if also \code{nmax} is high. \code{nmax} could be estimated with [find_nmax].
#'     For testing also \code{n_bp = 4} is possible See \code{experimental} setting.
#' @param bp_mingap numeric, smallest interval between two breakpoints (default = 5).
#' @param bp_min numeric, `bp_min`+1 is minimum allowed breakpoint position (default = 0).
#' @param bp_max numeric, `bp_max`-1 is maximum allowed breakpoint position.
#' @param nmax numeric parameter to truncate the tailing of the CDC (i.e. the length of \code{dfi} vector).
#'     Note, \code{nmax} should not be confused with \code{bp_max} (i.e. maximum breakpoint position).
#' @param of_weights vector with two elements, first is weight of the RMSE, second is weight of the MAE.
#'     Default is c(0.5, 0.5), i.e. equal weights. Sum of vector must be 1. To switch of one measure use
#'     \code{c(1, 0)} or \code{c(0,1)}. With the weighting more or less focus could be given to the upper parts
#'     of the DFI curve (i.e. when block length \code{n} for separation is between 1 and 10).
#' @param desc logical, if `TRUE` (recommended) DFI values are converted to be monotonically decreasing with [cummin()]
#' @param print logical, if `TRUE` best breakpoint estimates during calculation are printed (debug mode)
#' @param plotting logical, if `TRUE` the DFI curve, piecewise linear segments and the breakpoints
#'      are plotted with \code{plot()} whit DFI curve in blue and linear segments in red.
#' @param experimental logical, if `TRUE` four breakpoints can be estimated.
#'
#' @return Returns a list with 3 elements.
#' \item{breakpoints}{estimates for the n breakpoints with names `bp_n`}
#' \item{bias}{value of the objective function, default:
#'     `OF = 1/2 RMSE + 1/2 MAE`,
#'     where OF is to be minimized.}
#' \item{rel_contr}{Relative streamflow contributions between \code{bp_min}, the breakpoints and \code{bp_max},
#'     e.g. 2 breakpoints lead to 3 relative contributions, 3 breakpoints lead to 4 relative contributions.
#'     The first \code{rel_contr}-value is the fastest contribution to streamflow, the last \code{rel_contr}-value
#'     is the slowest contribution to streamflow. All contributions add up to 1.}
#' @references Stoelzle, M., Schuetz, T., Weiler, M., Stahl, K., & Tallaksen, L. M. (2020). Beyond binary baseflow separation: a delayed-flow index for multiple streamflow contributions. Hydrology and Earth System Sciences, 24(2), 849-867.
#' @export
#' @examples
#' # use dfi_example as an DFI vector with 121 values
#' find_bps(dfi_example, n_bp = 3, bp_max = 90, plotting = TRUE)
find_bps <- function(dfi,
					n_bp = 2,
					bp_mingap = 5,
					bp_min = 0,
					bp_max = length(dfi) - 1,
					nmax = length(dfi),
					of_weights = c(0.5, 0.5),
					desc = TRUE,
					print = FALSE,
					plotting = FALSE,
					experimental = FALSE) {

	if(length(nmax) != 1 | nmax > length(dfi)) {
		stop(paste0("nmax must be integer number and/or smaller than ", length(dfi),"."))
	}

	if(nmax < 6 * n_bp) {
		stop("Increase nmax.")
	}

	len <- length(dfi)
	if(nmax < length(dfi)) {
		len <- nmax
		dfi <- dfi[1:nmax]
	}
	if(class(dfi) != "numeric") {
		stop("DFI vector is not numeric vector.")
	}

	if(any(is.na(dfi))) {
		stop("DFI vector has NA values.")
	}
	if(len <= bp_max) {
		stop("DFI vector is too short or reduce bp_max, i.e. length(dfi) > bp_max")
	}
	if(bp_max < bp_min + 5){
		stop("Adjust \"bp_min\" or \"bp_max\"!" )
	}
	if(bp_mingap <= 2) {
		stop("\"min_gap\" is too small, should be 3 or larger.")
	}
	if(!n_bp %in% 1:4) {
		stop("Number of breakpoints must be 1,2,3 or 4 (experimental)")
	}

	if(n_bp == 4 & !experimental) {
		stop("Number of breakpoints = 4, please set experimental = TRUE")
	}

	if(sum(of_weights) != 1) {
		stop("Both weights must sum up to 1, please adjust of_weights.")
	}

	if(desc) {
		dfi <- cummin(dfi)
	}

	# breakpoint grid
	len <- length(dfi)
	pot_bp <- (bp_min+1):(bp_max-1)
	bp_grid <- expand.grid(rep(list(pot_bp),n_bp))
	names(bp_grid) <- paste0("bp_",1:n_bp)

	# create breakpoint combinations
	if (n_bp == 1) bp_grid <- as.matrix(pot_bp)

	if (n_bp == 2) {
	bp_grid <- subset(bp_grid, (bp_1 < bp_2 & bp_1 + bp_mingap <= bp_2))
	bp_grid <- as.matrix(bp_grid, rownames.force = FALSE)
	}
	if (n_bp == 3) {
	bp_grid <- subset(bp_grid, (bp_1 < bp_2 &
								bp_1 + bp_mingap <= bp_2 &
								bp_2 < bp_3 &
								bp_2 + bp_mingap <= bp_3 ))
	bp_grid <- as.matrix(bp_grid, rownames.force = FALSE)
	}

	if (n_bp == 4) {
		bp_grid <- subset(bp_grid, (bp_1 < bp_2 &
										bp_1 + bp_mingap <= bp_2 &
										bp_2 < bp_3 &
										bp_2 + bp_mingap <= bp_3 &
										bp_3 < bp_4 &
										bp_3 + bp_mingap <= bp_4 ))
		bp_grid <- as.matrix(bp_grid, rownames.force = FALSE)
	}


	# fit breakpoint model
	dummy <- 999
	best_bps <- NULL
	cat("Calculating breakpoints...")
	for (i in 1:nrow(bp_grid)) {

		bps <- bp_grid[i,]
		fit <- approx(x = c(0,bps,len-1), dfi[c(1,bps+1,len)], xout = 0:(len-1))$y
        OF <-  rmse(fit,dfi) * of_weights[1] + mae(fit, dfi) * of_weights[2]
    	if(OF < dummy){
			if(print) cat(i,bps,OF,"\n")
			dummy <- OF
			best_fit <- fit
			result <- list(bps_position = bps, bias = dummy )
		}

        #if(i %in% floor(nrow(bp_grid) * 1:5/5)) cat(paste0(round(i/nrow(bp_grid)*100,0)),"%  ")

	}
	cat("Done. \n\n")

result$rel_contr <- -diff(c(dfi[c(1, result$bps_position+1)], 0))
names(result$rel_contr) <- c(paste0("contr_", 1:length(result$rel_contr)))

if (plotting){
	plot(0:(len-1), dfi,
		 type = "l",
		 lwd = 1.15,
		 col = "blue",
		 bty = "l",
		 xaxs = "i", yaxs = "i",
		 ylim = c(0,1.025),
		 xlim = c(-2,nmax * 1.05),
		 ylab = "DFI (-)",
		 xlab = "Block length N")
	grid(lty = 1, lwd = 0.5)
	points(0:(len-1), best_fit, type = "l", col = "red")
	for (b in 1:length(result$bps_position)) {
		segments(x0 = result$bps_position[b],
			 y0 = dfi[result$bps_position[b]+1],
			 x1 = result$bps_position[b],
			 y1 = 0,
			 lty = 2, lwd = 0.85)
		points(result$bps_position[b],dfi[result$bps_position[b]+1], pch = 16)

	}
	points(0,1, pch = 16)
	points(nmax-1,dfi[nmax-1], pch = 16)



}


return(result)
}

