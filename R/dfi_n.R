#' Calculation of DFI for block length of n
#'
#' @description Common baseflow separation separates quick- and baseflow with a
#'   block length of n = 5 with \code{baseflow(q_obs, n = 5)}. To generate multiple separations
#'   for the DFI index \code{n} vary between 1 and \code{n_max} (e.g. 60, 90 or 120 days). To do this the
#'   function could be used with a \code{n} as a vector instead of a single integer (e.g. \code{baseflow(q_obs, n = 1:60)})
#'   Note, separation with \code{n=0} is not possible. The DFI of \code{n=1} is not 1 as due to the algorithm some
#'   streamflow peaks are separated from delayed flow.
#' @param q vector with streamflow series
#' @param n block length \code{n}. If \code{n} is a integer (vector of length one) a single
#'   delayed flow separation is performed. If \code{n} is a vector (with length > 1)
#'   multiple separations for all \code{n} values are calculated. To analyze later on the
#'   DFI curve it is recommended that \code{n} starts at 1 and is a continuous vector (e.g. 1,2,3,.... 58, 59, 60).
#'   But also variations like \code{n = c(1,5,10,15,30)} are possible.
#' @param add_zero logical, default is \code{TRUE}. If \code{TRUE}, \code{n=0} and \code{dfi=1} is added to
#'     output data.frame. Note that the \code{DFI} of a separation with \code{n=0} is by definition \code{DFI = 1}.

#' @return A data.frame with two columns: \code{n} for block length and \code{dfi} with the \code{DFI(n)} values.
#'     If \code{n} is a single integer the function returns a single integer (i.e. one \code{DFI(n)} value).
#' @export
#'
#' @examples
#' # same as BFI calculation
#' dfi_n(q_obs, n = 5)
#'
#' # 10 different separations based on various block length n
#' dfi_n(q_obs, n = 1:10)
#'
#' # only specific block lengths are used
#' dfi_n(q_obs, n = c(1,5,10,30,60,90), add_zero = FALSE)
#'
dfi_n <- function(q, n = 5, add_zero = TRUE) {

	if (0 %in% n) stop("DFI calculation not possible if n = 0. Set add_zero = TRUE.")

	if(length(n) == 1){
		bflow <- baseflow(q, block.len = n)
		valid <- !is.na(q) & !is.na(bflow)
		return(sum(bflow[valid]) / sum(q[valid]))
	} else {
		if(min(n) != 1) warning('If n is given as vector the minimum of n should be 1.')

		if(add_zero){
			df <- data.frame(n = 0, dfi = 1)
		}
		for (i in 1:length(n)) {
			bflow <- baseflow(q, block.len = n[i])
			valid <- !is.na(q) & !is.na(bflow)
			dfi <- (sum(bflow[valid]) / sum(q[valid]))
			if(!add_zero & i == 1) {
				df <- data.frame(n = n[i], dfi = dfi)
			} else {
				df <- rbind(df, c(n[i], dfi))
			}

		}
		return(df)
	}
}
