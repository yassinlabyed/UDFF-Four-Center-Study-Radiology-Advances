% MIT License
% 
% Copyright (c) 2025 yassinlabyed
% 
% Permission is hereby granted, free of charge, to any person obtaining a copy
% of this software and associated documentation files (the "Software"), to deal
% in the Software without restriction, including without limitation the rights
% to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
% copies of the Software, and to permit persons to whom the Software is
% furnished to do so, subject to the following conditions:
% 
% The above copyright notice and this permission notice shall be included in all
% copies or substantial portions of the Software.
% 
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
% IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
% FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
% AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
% LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
% OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
% SOFTWARE.

clc;
clear all;
close all;

pdff_thresholds = [5.75, 15.5, 21.35];    % Qadri

load results.mat 
data = results;
pdff = data.pdff_roi;
udff9c2= data.udff_9c2;
udff5c1 = data.udff_5c1;
udffdax = data.udff_dax;
age = data.age;
sex = categorical(data.gender); 
bmi = data.bmi;

% Logical condition to filter rows where pdff is not NaN
validPdff = ~isnan(pdff);

% Logical condition to filter rows where at least one udff (dax, 5c1, or 9c2) is not NaN
validUdff = ~isnan(udffdax) | ~isnan(udff5c1) | ~isnan(udff9c2);

% Combine conditions: only include rows with valid pdff and at least one valid udff
validRows = validPdff & validUdff;

% Filter the data
filteredData = data(validRows, :); % Assuming 'data' is a table or matrix

% Update variables with filtered data
pdff = pdff(validRows);
udff9c2 = udff9c2(validRows);
udff5c1 = udff5c1(validRows);
udffdax = udffdax(validRows);
age = age(validRows);
sex = sex(validRows);
bmi = bmi(validRows);


%-------------------------- select probe ----------------------------------
udffPorbe= udffdax; 
%--------------------------------------------------------------------------

% auc......................................................................
% Define logical arrays for adults and children
validAdults = age >= 18; % All adults in the dataset
validChildren = age < 18; % All children in the dataset

% AUC calculation for overall
[params_overall] = plot_auc(udffPorbe, pdff,pdff_thresholds);
auc_overall = params_overall.auc;
aucL_overall = params_overall.aucL; % Lower bound of 95% CI
aucR_overall = params_overall.aucR; % Upper bound of 95% CI

% AUC calculation for adults
[params_adults] = plot_auc(udffPorbe(validAdults), pdff(validAdults),pdff_thresholds);
auc_adults = params_adults.auc;
aucL_adults = params_adults.aucL; % Lower bound of 95% CI
aucR_adults = params_adults.aucR; % Upper bound of 95% CI

% AUC calculation for children
[params_children] = plot_auc(udffPorbe(validChildren), pdff(validChildren),pdff_thresholds);
auc_children = params_children.auc;
aucL_children = params_children.aucL; % Lower bound of 95% CI
aucR_children = params_children.aucR; % Upper bound of 95% CI

% Use bootstrap to compare AUCs between adults and children
params = compare_auc(udffPorbe(validAdults), pdff(validAdults), udffPorbe(validChildren), pdff(validChildren), pdff_thresholds);
pValues  = params.pValues







