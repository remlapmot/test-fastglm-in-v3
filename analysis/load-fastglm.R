# Use fastglm 0.1.4 in place of the version shipped in the r:v3 image.
#
# src/fastglm_0.1.4_R_x86_64-pc-linux-gnu.tar.gz is the pre-built binary from
# Posit Package Manager for Ubuntu 22.04 (jammy), which matches r:v3 (R 4.6).
# Downloaded from:
# https://packagemanager.posit.co/cran/__linux__/jammy/2026-11-22/src/contrib/fastglm_0.1.4.tar.gz
#
# Each action runs in a fresh container, so any action that needs fastglm
# 0.1.4 should run the block below before calling library(fastglm).

fastglm_lib <- file.path(tempdir(), "fastglm-lib")
dir.create(fastglm_lib, showWarnings = FALSE)
install.packages("src/fastglm_0.1.4_R_x86_64-pc-linux-gnu.tar.gz",
                 repos = NULL, lib = fastglm_lib)
.libPaths(c(fastglm_lib, .libPaths()))
library(fastglm)
stopifnot(packageVersion("fastglm") == "0.1.4")

# Check it works -------------------------------------------------------------
set.seed(1)
x <- cbind(1, matrix(rnorm(1000 * 3), ncol = 3))
y <- rbinom(1000, 1, plogis(x %*% c(-0.5, 1, -1, 0.5)))
fit <- fastglm(x, y, family = binomial())
ref <- glm.fit(x, y, family = binomial())
stopifnot(isTRUE(all.equal(unname(coef(fit)), unname(ref$coefficients),
                           tolerance = 1e-6)))

dir.create("output", showWarnings = FALSE)
writeLines(
  c(paste("fastglm version:", packageVersion("fastglm")),
    paste("loaded from:", find.package("fastglm")),
    "coefficients:",
    capture.output(print(coef(fit)))),
  "output/fastglm-check.txt"
)
