#' Find nmax based on low flow thresholds
#'
#' @param df data.frame with two columns, first column must be Date, second must be streamflow
#'     data.
#' @param n numeric vector
#'
#' @return A list.
#' @export
#'
#' @examples
#' find_nmax(q_data)
find_nmax <- function(df, n = 1:180){

	if (class(df) != "data.frame") {
		stop("Input data df_q must be a data.frame.")
	}

	if (class(df[,1]) != "Date") {
		stop("First column of data must be class of Date.")
	}

	names(df) <- c("date", "q")

	df$year  <- as.numeric(format(df$date, "%Y"))
	df$month <- as.numeric(format(df$date, "%m"))
	df$q7    <- stats::filter(df$q, rep(1 / 7, 7), sides = 1)

	mam <- mean(tapply(df$q7, df$year, FUN = min, na.rm = TRUE))
	mq  <- mean(tapply(df$q7, df$year, FUN = mean, na.rm = TRUE))

	mam_mq  <- mam/mq
	q95_q50 <- as.numeric(quantile(df$q7, probs = 0.05, na.rm=T) /
							quantile(df$q7, probs = 0.50, na.rm=T))
	q90_q50 <- as.numeric(quantile(df$q7, probs = 0.10, na.rm=T) /
						  	quantile(df$q7, probs = 0.50, na.rm=T))

	cdc <- dfi_n(df$q, n = n)

	if(any(min(cdc$dfi)> c(mam_mq, q95_q50, q90_q50))) {
		warning("Minimum of CDC might be lager than indices. Consider to use larger 1:n.")
	}

	bp_a <- which.min(abs(cdc$dfi-mam_mq))
	bp_b <- which.min(abs(cdc$dfi-q95_q50))
	bp_c <- which.min(abs(cdc$dfi-q90_q50))


	return(list(mam_mq = c(mam_mq, as.integer(bp_a)),
				q95_q50 = c(q95_q50, as.integer(bp_b)),
				q90_q50 = c(q90_q50, as.integer(bp_c))))
}
