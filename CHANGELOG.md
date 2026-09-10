### v4.10.9.6 - 2026-09-10
- **Improve**: use theta_norm to replace rgeneOpt_gamma in the ctl file.

### v4.10.9.5 - 2026-09-01
- **Improved**: under clock = 4, `mcmctree.c` OU process changed to GOU with sigma2, reversion (alpha by some people), theta = log(ropt) + sigma2 / (2 * alpha). In v4.10.9.4, theta -> reversion, log(rgeneOpt) -> theta - sigma2 / (2 * alpha), s2 -> s2


### v4.10.9.4 - 2026-06-15
- **New**: OU implemented (clock = 4, rgeneOpt\_gamma, theta\_gamma)
- **Improved**: `mcmc.txt` output improved
- **Fixed**: `mcmctree.c` well formatted to make it well aligned with ziheng's coding style

### v4.10.9.3 - 2026-06-05
- **Improved**: drift now output as drift instead of exp(drift) in mcmc.txt

### v4.10.9.2 - 2026-06-04
- **Fixed**: full GBM correctly work under norm prior for the drift

### v4.10.9.1 — 2025-08-25
- **New**: new clock models for `MCMCtree` full-GBM for the AR clock rate model, by specifying in `mcmctree.ctl` clock = 30 (original), 31 (log-rate martingale), or 32 (full GBM with a drift param).
