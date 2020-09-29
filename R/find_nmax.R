#' Find maximum breakpoint position based on low flow threshold(s)
#'
#' @description In order to constrain breakpoint analysis on DFI curves (CDCs = Characteristic
#'     Delay Curves) the length of 1:N delayed flow separations should be as short as possible. Normally the
#'     position N is searched where the CDCs is flattening out (slope = 0). To do this the DFI values of 1:N
#'     separations are compared against typical low flow indices (like the MAM/MQ). The low flow indices
#'     ranging between 0 and 1 indicating the low flow sensitivity. High index values (e.g. 0.60) indicating more
#'     stable flow regimes with larger catchment storages, lower index values (e.g. 0.20) indicating rather flashy
#'     flow regimes with faster recession behavior. The maximum breakpoint position is estimated by estimating the
#'     DFI value with a separation block size of N that match the index value.
#'
#' @param df data.frame with two columns, first column must be Date, second must be streamflow
#'     data.
#' @param n numeric vector
#' @param desc logical, if `TRUE` DFI values are converted to be monotonically decreasing with [cummin()]
#' @param lowflow_index Which Low Flow Index should be used? MAM/MQ (default), Q95/Q50, Q90/Q50.
#'     Index names are "mam_mq", "q95_q50" or "q90_q50". Note that especially in highly seasonal regimes
#'     the deviation between the indices might be large(r).
#' @return Function returns a list with two elements: \code{$index_value} and \code{$bp_nmax}
#'     \item{index_value}{Index value of the used low flow index ranging between 0 and 1.
#'     Higher values indicating more stable flow regimes and less low flow sensitivity.}
#'     \item{bp_nmax}{Position \code{N} of breakpoint where absolute deviation between \code{DFI_N}
#'     and low flow index is minimal (considering all \code{DFI} values).}
#' @export
#'
#' @examples
#' find_nmax(q_data)
find_nmax <- function(df, n = 1:180, desc = TRUE, lowflow_index = c("mam_mq")){

	if (class(df) != "data.frame") {
		stop("Input data df_q must be a data.frame.")
	}

	if (class(df[,1]) != "Date") {
		stop("First column of data must be class of Date.")
	}

	if (!lowflow_index %in% c("mam_mq", "q95_q50", "q90_q50")) {
		stop("Please set low flow index to mam_mq, q95_q50 or q90_q50")
	}

	names(df) <- c("date", "q")

	df$year  <- as.numeric(format(df$date, "%Y"))
	df$month <- as.numeric(format(df$date, "%m"))
	df$q7    <- stats::filter(df$q, rep(1 / 7, 7), sides = 1)

	if (lowflow_index == "mam_mq"){
		mam <- mean(tapply(df$q7, df$year, FUN = min, na.rm = TRUE))
		mq  <- mean(tapply(df$q7, df$year, FUN = mean, na.rm = TRUE))
		index  <- mam/mq
	}
	if (lowflow_index == "q95_q50"){
		index  <- as.numeric(quantile(df$q7, probs = 0.05, na.rm=T) /
							quantile(df$q7, probs = 0.50, na.rm=T))
	}
	if (lowflow_index == "q90_q50"){
		index  <- as.numeric(quantile(df$q7, probs = 0.10, na.rm=T) /
							quantile(df$q7, probs = 0.50, na.rm=T))
	}

	cdc <- dfi_n(df$q, n = n, desc = desc)

	if(any(min(cdc$dfi)> index)) {
		warning("Minimum of CDC (i.e. the min(DFI_N)) might be larger than the index value.\nConsider to increase N in 1:N.")
	}

	bp <- min(which.min(abs(cdc$dfi-index)))

	return(list(index_value = index,
				bp_nmax = bp))
}
