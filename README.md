# delayedflow

Package website https://modche.github.io/delayedflow/

Understanding components of the total streamflow is important to assess the ecological functioning of rivers. Here hydrologists asks how much water comes from different sources like snow melt, groundwater, lakes and sustains streamflow.

Binary or two-component separation of streamflow into a quick and a slow (often referred to as baseflow) component are often based on arbitrary choices of separation parameters and also merge different delayed components into one baseflow component (e.g. snow melt and groundwater contribution). As streamflow generation during dry weather often results from drainage of multiple sources, it is proposed to extend the BFI by a delayed-flow index (DFI) considering the dynamics of multiple delayed contributions to streamflow. 

The DFI is based on characteristic delay curves (CDCs) where the identification of breakpoint (BP) estimates helps to avoid rather subjective separation parameters and allows for distinguishing four types of delayed streamflow contributions.


### 1. Introduction

The `delayedflow` package in R is developed to make it quick and easy to perform a delayed flow separation on the basis of streamflow (discharge) date only. The package is based on the publication from  [Stoelzle et al. (2020)](https://hess.copernicus.org/articles/24/849/2020/) where common binary baseflow separation into quick- and baseflow is advanced by the DFI (Delayed Flow Index) to quantify multiple delayed contributions to streamflow.

Specifically, the R package performs:

 - DFI separations with variable block length N (baseflow separation has fixed N = 5 days)
 - Estimation of breakpoint(s)
 - Quantification of relative streamflow contributions in different delay classes
 - Couple of minor analyses

### 2. Package installation

The `delayedflow` package is in beta testing now. It is not available on CRAN.

```{R}
# ----- use package in R  -----
#install.packages("devtools")
devtools::install_github("modche/delayedflow")
```

### 3. Vignette / Manual

[Website with package documentation](https://modche.github.io/delayedflow/)

```{R}
# ----- get help in R after installation  -----
help(package = "delayedflow")
```

### 3. Reporting issues

Please report any issue you have with the package on

https://github.com/modche/delayedflow/issues

This is especially helpful to eliminate bugs and improve the functionality of the package.

### 4. References

 1) Stoelzle, M., Schuetz, T., Weiler, M., Stahl, K., & Tallaksen, L. M. (2020). Beyond binary baseflow separation: a delayed-flow index for multiple streamflow contributions. Hydrology and Earth System Sciences, 24(2), 849-867, https://hess.copernicus.org/articles/24/849/2020/.

 2) Baseflow function based on the lfstat package.
https://cran.r-project.org/web/packages/lfstat/index.html
