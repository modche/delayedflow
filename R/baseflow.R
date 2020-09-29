#' Calculation of baseflow based on smoothed minima method
#'
#' @description Original \code{baseflow} function from the \code{lfstat} package.
#'
#' @param x numeric vector with observed streamflow, normally given in daily values
#' @param tp.factor numeric vector, turning point factor
#' @param block.len numeric vector, block size of filter to set flow minima
#'
#' @return Baseflow series.
#' @export
#'
#' @references lfstat: Calculation of Low Flow Statistics for Daily Stream Flow Data
#'     D. Koffler, T. Gauster, T., and G. Laaha (https://CRAN.R-project.org/package=lfstat)
#'
#' @examples
#'\dontrun{
#'baseflow(q_data$q_obs, block.len = 10)
#'}
baseflow <- function (x, tp.factor = 0.9, block.len = 5)
{
    x <- as.numeric(x)
    y <- matrix(c(x, rep(NA, -length(x) %% block.len)), nrow = block.len)
    offset <- seq.int(0, ncol(y) - 1) * block.len
    idx.min <- apply(y, 2, which.min.na) + offset
    block.min <- x[idx.min]
    cv.mod <- tp.factor * tail(head(block.min, -1), -1)
    is.tp <- cv.mod <= tail(block.min, -2) & cv.mod <= head(block.min,
        -2)
    is.tp <- c(F, is.tp)
    if (sum(is.finite(block.min[is.tp])) < 2)
        return(rep_len(NA, length(x)))
    bf <- approx(x = idx.min[is.tp], y = block.min[is.tp], xout = seq_along(x))$y
    return(pmin(bf, x))
}
