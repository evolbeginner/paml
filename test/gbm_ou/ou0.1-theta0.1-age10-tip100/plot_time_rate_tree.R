#! /usr/bin/env Rscript

suppressPackageStartupMessages({
    library(ggtree)
    library(ggplot2)
    library(gridExtra)
    library(scales)
    library(phytools)
    library(ape)
})

get_rate_range <- function(rate_files, is_log = FALSE) {
    rates <- unlist(lapply(rate_files, function(f) read.tree(f)$edge.length))
    if (is_log) rates <- log(rates)
    range(rates, na.rm = TRUE)
}

parse_args <- function(args) {
    timetrees <- c()
    ratetrees <- c()
    output <- "output.pdf"
    is_log <- FALSE
    rate_range <- NULL

    i <- 1
    while (i <= length(args)) {
        if (args[i] == "-t") {
            timetrees <- c(timetrees, args[i + 1])
            i <- i + 2
        } else if (args[i] == "-r") {
            ratetrees <- c(ratetrees, args[i + 1])
            i <- i + 2
        } else if (args[i] == "-o") {
            output <- args[i + 1]
            i <- i + 2
        } else if (args[i] == "--log") {
            is_log <- TRUE
            i <- i + 1
        } else if (args[i] == "--rate_range") {
            rate_range <- as.numeric(strsplit(args[i + 1], ",")[[1]])
            i <- i + 2
        } else {
            i <- i + 1
        }
    }

    list(
        timetrees = timetrees,
        ratetrees = ratetrees,
        output = output,
        is_log = is_log,
        rate_range = rate_range
    )
}

extract_ci_bars <- function(tree, tree_df, tree_height) {
    labels <- tree$node.label

    if (is.null(labels) || length(labels) == 0) {
        return(NULL)
    }

    n_tip <- length(tree$tip.label)

    ci <- lapply(seq_along(labels), function(i) {
        lab <- labels[i]

        if (is.na(lab) || !grepl("^[0-9.eE]+-[0-9.eE]+$", lab)) {
            return(NULL)
        }

        vals <- as.numeric(strsplit(lab, "-")[[1]])

        if (length(vals) != 2 || any(is.na(vals))) {
            return(NULL)
        }

        node_id <- n_tip + i
        y <- tree_df$y[tree_df$node == node_id]

        if (length(y) == 0 || is.na(y)) {
            return(NULL)
        }

        data.frame(
            node = node_id,
            ci_min = vals[1],
            ci_max = vals[2],
            y = y
        )
    })

    ci <- do.call(rbind, ci)

    if (is.null(ci) || nrow(ci) == 0) {
        return(NULL)
    }

    ci
}

make_plot <- function(time_file, rate_file, rate_range, is_log = FALSE) {
    time_tree <- read.tree(time_file)
    rate_tree <- read.tree(rate_file)

    if (is_log) {
        rate_tree$edge.length <- log(rate_tree$edge.length)
    }

    tree_height <- max(phytools::nodeHeights(time_tree))
    max_label_length <- max(nchar(time_tree$tip.label))

    rate_data <- data.frame(
        node = time_tree$edge[, 2],
        rate = rate_tree$edge.length
    )

    p <- ggtree(time_tree, aes(color = rate), size = 1.2) %<+% rate_data

    tree_df <- p$data
    ci_bars <- extract_ci_bars(time_tree, tree_df, tree_height)

    p <- p +
        scale_x_reverse(
            limits = c(tree_height * 1.05, -0.08 * tree_height),
            breaks = pretty_breaks(n = 6)
        ) +
        scale_color_gradientn(
            name = "Substitution rate",
            colors = c(
                "#2b83ba", "#74add1", "#ffffbf",
                "#fdae61", "#d7191c"
            ),
            limits = rate_range,
            breaks = pretty_breaks(n = 6)(rate_range),
            guide = guide_colorbar(
                direction = "vertical",
                barheight = 12,
                barwidth = 1.2,
                title.position = "top",
                title.hjust = 0.5
            )
        ) +
        geom_tiplab(
            size = 3,
            align = TRUE,
            hjust = 0,
            offset = -0.02 * tree_height
        ) +
        theme_tree2() +
        theme(
            legend.position = "right",
            legend.title = element_text(size = 9, face = "bold"),
            legend.text = element_text(size = 8),
            plot.margin = unit(c(1, max_label_length * 0.2, 1, 1), "cm")
        )

    if (!is.null(ci_bars)) {
        p <- p +
            geom_segment(
                data = ci_bars,
                aes(x = ci_max, xend = ci_min, y = y, yend = y),
                inherit.aes = FALSE,
                color = "grey40",
                linewidth = 1.1,
                alpha = 0.65
            )
    }

    p
}

args <- parse_args(commandArgs(trailingOnly = TRUE))

if (length(args$timetrees) == 0) {
    stop("Usage: Rscript script.R -t time_tree.nwk -r rate_tree.nwk [-t ... -r ...] [-o output.pdf] [--log] [--rate_range min,max]")
}

if (length(args$timetrees) != length(args$ratetrees)) {
    stop("Number of -t time trees must equal number of -r rate trees.")
}

if (is.null(args$rate_range)) {
    args$rate_range <- get_rate_range(args$ratetrees, args$is_log)
    args$rate_range[2] <- args$rate_range[2] * 1.2
} else if (args$is_log) {
    args$rate_range <- log(args$rate_range)
}

plots <- mapply(
    make_plot,
    args$timetrees,
    args$ratetrees,
    MoreArgs = list(
        rate_range = args$rate_range,
        is_log = args$is_log
    ),
    SIMPLIFY = FALSE
)

pdf(
    args$output,
    width = ifelse(length(plots) == 1, 14, 22),
    height = max(8, 8 * length(plots))
)

grid.arrange(
    grobs = plots,
    ncol = 1
)

dev.off()

cat("Created", length(plots), "tree plot(s):", args$output, "\n")
cat("Rate range:", signif(args$rate_range[1], 3), "to", signif(args$rate_range[2], 3), "\n")
