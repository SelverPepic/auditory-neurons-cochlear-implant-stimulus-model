function y_new = random_correlated(x,y,rho_corr)
% INPUTS:
%   x,y - vectors of random numbers to be correlated
%   sigma_corr - correlation factor
% OUTPUT:
%   y_new - new vector of rand. numbers y, now correlated with x

% FROM MATLAB CENTRAL
    % A useful fact is that if you have a random vector x with covariance matrix ?,
    % then the random vector Ax has mean AE(x) and covariance matrix ?=A?AT.

    % So, if you start with data that has mean zero, multiplying by A will not change
    % that, so your first requirement is easily satisfied.

    % Let's say you start with (mean zero) uncorrelated data (covariance matrix is diagonal)
    % Since we're talking about the correlation matrix, let's just take C=I.
    % You can transform this to data with a given covariance matrix by choosing A
    % to be the cholesky square root of C - then Ax would have the desired covariance matrix ?.

    C = [1 rho_corr; rho_corr 1];
    [xy_new] = [x y] * chol(C);
    y_new = xy_new(:,2);
% END OF FUNCTION

% "offline" test of function, if needed
    %N = 1000;
    %x = randn(N,1);
    %y = randn(N,1);
    %r = corr(x,y);
    %disp(r);
    %rho_corr = 0.5;

    %C = [1 rho_corr; rho_corr 1];
    %[xy_new] = [x y] * chol(C);
    %x_new = xy_new(:,1);
    %y_new = xy_new(:,2);
    %r_new = corr(x_new,y_new);
    %disp(r_new);