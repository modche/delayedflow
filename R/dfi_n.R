#' Calculation of DFI for block length of N
#'
#' @param q streamflow series
#' @param n block length
#' @param ... other parameters passed to function
#'
#' @return
#' @export
#'
#' @examples
#' dfi_n(q_obs, n = 2:5)
dfi_n <- function(q, n = 5) {

	if(length(n) == 1){
		bflow <- baseflow(q, block.len = n)
		valid <- !is.na(q) & !is.na(bflow)
		return(sum(bflow[valid]) / sum(q[valid]))
	} else {
		if(min(n) != 1) stop('If n is given as vector the minimum of n should be 1.')
		df <- data.frame(n = 0, dfi = 1)
		for (i in 1:length(n)) {
			bflow <- baseflow(q, block.len = n[i])
			valid <- !is.na(q) & !is.na(bflow)
			dfi <- (sum(bflow[valid]) / sum(q[valid]))
			df <- rbind(df, c(n[i], dfi))
		}
		return(df)
	}
}
