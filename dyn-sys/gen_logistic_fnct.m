function [y] = gen_logistic_fnct(x, a, b, c, r)
y = (a*exp(c*r) + b*exp(r*x)) ./ (exp(c*r) + exp(r*x));
end