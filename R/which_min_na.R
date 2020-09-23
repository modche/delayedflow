#' Helper Function
#'
#' @description Calculation of minimum position in a vector with NA values.
#'
#' @param x numeric verctor
#'
#' @return Position of minimum value in the vector
#' @export
#'
#' @examples
#' which.min.na(c(2,3,4,1,NA,6))
which.min.na <- function (x)
{
    idx <- which.min(x)
    if (!length(idx))
        idx <- NA
    return(idx)
}
