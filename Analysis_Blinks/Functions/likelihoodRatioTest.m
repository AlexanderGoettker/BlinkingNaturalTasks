function [LR,df,p] = likelihoodRatioTest(reducedModel,fullModel)
    LR = 2 * (fullModel.LogLikelihood - reducedModel.LogLikelihood);
    df = fullModel.NumCoefficients - reducedModel.NumCoefficients;
    p = 1 - chi2cdf(LR,df);
end