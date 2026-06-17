# drift1-tip100

This folder contains a simulation and dating example built around the `drift1-tip100` setting.

## What is in this folder

- `sim/tree/time.tre`: the time-scaled reference tree used for the simulation
- `sim/tree/rate.tre`: the same tree with branch rates mapped onto it
- `rate.pdf`: a visualization of the rate mapping on the time tree
- `lograte.pdf`: a visualization of the log-rate mapping on the time tree
- `dating/ori/combined/`: the main dating output directory for the original run

## Rate mapping files

`rate.pdf` and `lograte.pdf` both summarize branch-rate information projected onto the time tree in:

- `sim/tree/time.tre`
- `sim/tree/rate.tre`

The difference is the scale used for display:

- `rate.pdf` shows rates on the original rate scale
- `lograte.pdf` shows the same information on a log-rate scale

## `dating/ori/combined/`

This directory contains the combined dating results and outputs from multiple clock models.

The main clock variants are:

- `clock3`: rate-martingale GBM
- `clock31`: lograte-martingale GBM
- `clock32`: full GBM
- `clock4`: OU

Representative summary files:

- `summary.clock3.txt`
- `summary.clock31.txt`
- `summary.clock32.txt`
- `summary.clock4.txt`

Each summary file records the fitted parameters for the corresponding model.

## Meaning of the `mean_rate_*` files

The `mean_rate_*` outputs summarize estimated rate behavior across the tree. In this folder they are:

- `mean_rate_params.tsv`: tabular summary of the mean-rate parameter estimates
- `mean_rate_param.pdf`: plotted version of the same summary

These files are used to compare how mean rate changes are captured under the different clock models.

## Model parameter interpretation

Based on the model summaries:

- `clock3` reports `mu`, `sigma2`, and `drift`
- `clock31` reports `mu`, `sigma2`, and `drift`
- `clock32` reports `mu`, `sigma2`, and `drift`
- `clock4` reports `mu`, `sigma2`, `rgeneOpt`, and `theta`

## Notes

- The `dating/ori/combined/` directory also contains the corresponding `mcmctree.*` outputs, tree files, and intermediate run artifacts.
- If you want, this README can be expanded with a file-by-file inventory or a short explanation of how the clock models differ mathematically.
