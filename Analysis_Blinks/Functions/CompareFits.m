function [] = CompareFits(x,y)

% Linear: y = b0 + b1*x
mdl_linear = fitlm(x, y, 'linear');

% Quadratic: y = b0 + b1*x + b2*x^2
mdl_quadratic = fitlm(x, y, 'quadratic');

%% Compare model quality
fprintf('             Adj. R2      AIC        BIC\n');
fprintf('Linear:      %.3f       %.2f      %.2f\n', ...
    mdl_linear.Rsquared.Adjusted, ...
    mdl_linear.ModelCriterion.AIC, ...
    mdl_linear.ModelCriterion.BIC);

fprintf('Quadratic:   %.3f       %.2f      %.2f\n', ...
    mdl_quadratic.Rsquared.Adjusted, ...
    mdl_quadratic.ModelCriterion.AIC, ...
    mdl_quadratic.ModelCriterion.BIC);



%% Compare the results 
% Residual sum of squares
RSS_linear    = sum(mdl_linear.Residuals.Raw.^2);
RSS_quadratic = sum(mdl_quadratic.Residuals.Raw.^2);

% Number of observations
n = length(y);

% Number of fitted parameters
% linear: intercept + x = 2
% quadratic: intercept + x + x^2 = 3
p_linear = 2;
p_quad   = 3;

% Difference in number of parameters
df1 = p_quad - p_linear;

% Residual degrees of freedom of the more complex model
df2 = n - p_quad;

% F statistic
F = ((RSS_linear - RSS_quadratic) / df1) / ...
    (RSS_quadratic / df2);

% p-value
p = 1 - fcdf(F, df1, df2);

fprintf('F(%d,%d) = %.3f, p = %.4f\n', df1, df2, F, p);

%% Plot both fits 
% X-values for smooth curves
xfit = linspace(min(x), max(x), 200)';

% Predictions + 95% confidence intervals
[yLin, ciLin]   = predict(mdl_linear, xfit);
[yQuad, ciQuad] = predict(mdl_quadratic, xfit);

figure
hold on

% Raw data
scatter(x, y, 35, 'filled');

% Linear confidence interval
fill([xfit; flipud(xfit)], ...
     [ciLin(:,1); flipud(ciLin(:,2))], ...
     [0.7 0.7 0.7], ...
     'FaceAlpha', 0.25, ...
     'EdgeColor', 'none');

% Quadratic confidence interval
fill([xfit; flipud(xfit)], ...
     [ciQuad(:,1); flipud(ciQuad(:,2))], ...
     [0.5 0.5 0.5], ...
     'FaceAlpha', 0.25, ...
     'EdgeColor', 'none');

% Fitted lines
hLin  = plot(xfit, yLin, '-', 'LineWidth', 2);
hQuad = plot(xfit, yQuad, '--', 'LineWidth', 2);

xlabel('X');
ylabel('Y');

legend([hLin hQuad], ...
    {'Linear fit', 'Quadratic fit'}, ...
    'Location', 'best');

box off
