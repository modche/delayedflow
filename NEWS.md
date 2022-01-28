# delayedflow 0.1 (2020-ongoing)

## Major changes 

- Initial release with major functions `dfi_n()` and `find_bps()` and two datasets
- `baseflow()` function is used directly from `lfstat` package as implementation there is really fast
- so far no package dependencies, i.e. no addtional packages will be installed when `delayedflow` is used
- beta testing

### delayedflow 0.11 (2020)

- adding function `find_nmax()` to derive a `nmax` value.
- change many parameter names to more meaningful terms (e.g. `bp_mingap`).
- `mam_mq` as delaut low flow index, only one index output is now possible.

### delayedflow 0.20 (2021-2022)

- now up to 4 breakpoints can be estimated in `find_bps()`
- smaller corrections of typos and adjusted outputs
- Using pgkdown 2.0 as website now.
