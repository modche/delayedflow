# delayedflow package for R

Package website https://modche.github.io/delayedflow/

### 1. Hydrological background

The `delayedflow` package in R is developed to perform a delayed-flow separation using streamflow data only. Commonly daily data is used. The package is based on the publication from  [Stoelzle et al. (2020)](https://hess.copernicus.org/articles/24/849/2020/) where common binary baseflow separation into quick- and baseflow is advanced by the DFI (Delayed Flow Index) to quantify multiple delayed contributions to streamflow. Normally 3-4 delayed contributions are separated by this method.

Specifically, the R package performs:

 - DFI separations with variable block length N (baseflow separation has fixed N = 5 days)
 - Estimation of n breakpoint(s)
 - Quantification of relative streamflow contributions [0,1] in different delay classes
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

Some example workflows are given in the Articles section.

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
