stopifnot(is.numeric(Rcpp::evalCpp('2 + 2')))
print('Rcpp test passed')
