#!/usr/bin/env bash
################################################################################
# It was found that using chips of intermediate density will help the imputation
# rate.
# Previously, I had 8k and 606k data.  There is a big gap to directly impute
# the missing genotypes on the 8k chips.
# I have asked chip provides for chips of other densities to test step
# imputation.
# I now realized that this is not necessary.
# I then seek a strategy here to find best loci sets of intermediate densities. 
# The easiest way that I can think about is to impute mid-points step by step:
#     e.g., let s be the shared, numbers shows the mid points of each step
#         step 0: s.......0.......s
#         step 1: s...1...0...1...s
#         step 2: s.2.1.2.0.2.1.2.s
#         step 3: s323132303231323s
#     For the missing loci on chromosome ends, add one by one, or two by two.
# I use chromosome 26 for this test

