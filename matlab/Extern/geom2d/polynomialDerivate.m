function deriv = polynomialDerivate(poly)
%POLYNOMIALDERIVATE derivate a polynomial
%
%   DERIV = polynomialDERIVATE(POLY)
%   POLY is a row vector of [n+1] coefficients, in the form:
%       [a0 a1 a2 ... an]
%   DERIV has the same format, with length n:
%       [a1 a2*2 ... an*n]
%
%
%   Example
%   T = polynomialDerivate([2 3 4])
%   returns:
%   T = [3 8]
%
%   See also
%
%
% ------
% Author: David Legland
% e-mail: david.legland@nantes.inra.fr
% Created: 2007-02-23
% Copyright 2007 INRA - BIA PV Nantes - MIAJ Jouy-en-Josas.
% Licensed under the terms of the LGPL, see the file "license.txt"


% create the derivation matrices
matrix = diag(0:length(poly)-1);

% compute coefficients of first derivative polynomials
deriv = circshift(poly*matrix, [0 -1]);


