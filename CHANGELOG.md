### v4.10.9.3 - 2026-06-05
- **Improved function**: drift now output as drift instead of exp(drift) in mcmc.txt

### v4.10.9.2 - 2026-06-04
- **Fixed bugs:** full GBM correctly work under norm prior for the drift

### v4.10.9.1 — 2025-08-25
- **New features:** new clock models for `MCMCtree` full-GBM for the AR clock rate model, by specifying in `mcmctree.ctl` clock = 30 (original), 31 (log-rate martingale), or 32 (full GBM with a drift param).
