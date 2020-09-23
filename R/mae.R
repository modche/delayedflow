#' Mean Absolute Error
#'
#' @param sim numeric, simulated values
#' @param obs numeric, observed values
#'
#' @return Mean absolute error between sim and obs.
#' @export
#'
#' @examples
#' mae(c(1:3), (2:4))
mae = function(sim, obs){
	mean(abs(sim - obs))
}
