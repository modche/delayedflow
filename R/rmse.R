#' Root Mean Square Error
#'
#' @param sim numeric with simulated values
#' @param obs numeric with observed values
#'
#' @return Root mean square error (rmse) between sim and obs.
#' @export
#'
#' @examples
#' rmse(c(1:3), c(1, 3, 5))
rmse = function(sim, obs){
	sqrt(mean((sim - obs)^2))
}
