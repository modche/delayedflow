#' Example data
#'
#' @description Example of DFI values. This is dummy data. A vector with 121 \code{DFI}-values between 1 and 0.
#'     The index is decreasing monotonously with larger n.
#'     This can be used for testing the [find_bp] function.
#'
#' @docType data
#'
#' @format vector data
#' @examples
#' data(dfi_example)
#' dfi_example
#'
#' find_bps(dfi = dfi_example, n_bp = 1, plotting = TRUE)
"dfi_example"
