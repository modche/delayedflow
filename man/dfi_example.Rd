% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/data.R
\docType{data}
\name{dfi_example}
\alias{dfi_example}
\title{Example data}
\format{
vector data
}
\usage{
dfi_example
}
\description{
Example of DFI values. This is dummy data. A vector with 121 \code{DFI}-values between 1 and 0.
The index is decreasing monotonously with larger n.
This can be used for testing the \link{find_bps} function.
}
\examples{
data(dfi_example)
dfi_example

find_bps(dfi = dfi_example, n_bp = 2, plotting = TRUE)
}
\keyword{datasets}
