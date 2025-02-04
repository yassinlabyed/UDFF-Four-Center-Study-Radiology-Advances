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

function [params] = plot_auc_comparison(udff_groups, pdff, pdff_thresholds)

    % Group names for labeling the plots
    groupNames = {'DAX', '5C1', '9C2', 'Random Probe'};
    
    % Define the comparison labels for each threshold
    comparisonLabels = {'S0 vs S1-3', 'S0-1 vs S2-3', 'S1-2 vs S3'};
    
    nGroups = length(udff_groups);  % Number of groups (4: DAX, 5C1, 9C2, Random Probe)
    nBoot = 1000;  % Number of bootstrap samples

    % Initialize arrays to store results
    Auc = zeros(nGroups, length(pdff_thresholds), 3);  % AUC for each group and threshold
    pValues = zeros(length(pdff_thresholds), 1);  % p-values for comparing AUCs across groups

    % Initialize arrays for storing positive and negative counts
    Np = zeros(nGroups, length(pdff_thresholds));
    Nn = zeros(nGroups, length(pdff_thresholds));

    % Define custom colors for each group
    colors = [
        0, 153/255, 153/255;        % #009999 for DAX
        255/255, 210/255, 0;        % #ffd200 for 5C1
        236/255, 102/255, 2/255;    % #ec6602 for 9C2
        231/255, 0, 29/255;         % #e7001d for Random Probe
    ];

    % Initialize cell arrays for storing True Positive Rate (TPR) and False Positive Rate (FPR)
    TPR = cell(nGroups, length(pdff_thresholds));
    FPR = cell(nGroups, length(pdff_thresholds));

    % Loop through each PDFF threshold (representing different comparisons)
    for target = 1:length(pdff_thresholds)
        pdff_target = pdff_thresholds(target);
        pdff_labels = pdff > pdff_target;  % Binary labels for PDFF (same across all groups)

        % Compute AUC for each group
        for g = 1:nGroups
            udff = udff_groups{g};  % UDFF for the current group

            % Filter valid rows (non-NaN values)
            valid_rows = ~isnan(udff) & ~isnan(pdff);
            udff = udff(valid_rows);
            pdff_filtered = pdff(valid_rows);
            pdff_labels_filtered = pdff_labels(valid_rows);

            % Count positive and negative samples
            Np(g, target) = sum(pdff_labels_filtered);  % Number of positives
            Nn(g, target) = length(pdff_labels_filtered) - Np(g, target);  % Number of negatives

            % Calculate AUC and ROC curve for the group
            [FPR{g, target}, TPR{g, target}, ~, Auc_temp] = perfcurve(pdff_labels_filtered, udff, 1, 'NBoot', nBoot);
            Auc(g, target, :) = Auc_temp;  % Store AUC and its confidence interval
        end
        
        % Plot ROC curves for this comparison in a separate figure
        figure, clf; hold on;
        for g = 1:nGroups
            % Plot FPR and TPR (focus on the first column which has the actual values)
            plot(FPR{g, target}(:, 1), TPR{g, target}(:, 1), 'LineWidth', 2, 'color', colors(g, :));
        end
        
        % Customize the plot
        xlabel('False Positive Rate (FPR)');
        ylabel('True Positive Rate (TPR)');
        grid on;
%         title(comparisonLabels{target});
        
        % Create legend with AUC values for each group
        legend(...
            ['DAX AUC = ' sprintf('%.2f (%.2f\x2013%.2f)', Auc(1, target, 1), Auc(1, target, 2), Auc(1, target, 3))], ...
            ['5C1 AUC = ' sprintf('%.2f (%.2f\x2013%.2f)', Auc(2, target, 1), Auc(2, target, 2), Auc(2, target, 3))], ...
            ['9C2 AUC = ' sprintf('%.2f (%.2f\x2013%.2f)', Auc(3, target, 1), Auc(3, target, 2), Auc(3, target, 3))], ...
            ['RST AUC = ' sprintf('%.2f (%.2f\x2013%.2f)', Auc(4, target, 1), Auc(4, target, 2), Auc(4, target, 3))], ...
            'Location', 'southeast');

    end

    % Return the results
    params.Auc = Auc;
    params.pValues = pValues;
    params.Np = Np;
    params.Nn = Nn;
end
