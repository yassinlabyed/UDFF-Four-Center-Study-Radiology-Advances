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

function [params] = compare_auc_multigroups(udff_groups, pdff_groups, pdff_thresholds)

    nGroups = length(udff_groups);  % Number of groups
    nBoot = 1000;  % Number of bootstrap samples
    
    % Initialize arrays to store results
    Auc = zeros(nGroups, length(pdff_thresholds), 3);  % AUC for each group and threshold
    pValues = zeros(length(pdff_thresholds), 1);  % p-values for comparing AUCs across groups
    
    % Initialize arrays for storing positive and negative counts
    Np = zeros(nGroups, length(pdff_thresholds));
    Nn = zeros(nGroups, length(pdff_thresholds));
    
    for target = 1:length(pdff_thresholds)
        pdff_target = pdff_thresholds(target);
        pdff_labels = cell(nGroups, 1);
        
        % Compute AUC for each group
        for g = 1:nGroups
            udff = udff_groups{g};
            pdff = pdff_groups{g};
            
            % Filter valid rows (non-NaN values)
            valid_rows = ~isnan(udff) & ~isnan(pdff);
            udff = udff(valid_rows);
            pdff = pdff(valid_rows);
            
            % Create binary labels based on the pdff threshold
            pdff_labels{g} = pdff > pdff_target;
            Np(g, target) = sum(pdff_labels{g});  % Number of positives
            Nn(g, target) = length(pdff_labels{g}) - Np(g, target);  % Number of negatives
            
            % Calculate AUC for the group
            [~, ~, ~, Auc_temp] = perfcurve(pdff_labels{g}, udff, 1, 'NBoot', nBoot);
            Auc(g, target, :) = Auc_temp;  % Store AUC and its confidence interval
        end
        
        % Bootstrap AUCs for comparison between groups
        bootstrapAucs = cell(nGroups, 1);
        
        for g = 1:nGroups
            udff = udff_groups{g};
            pdff = pdff_groups{g};
            valid_rows = ~isnan(udff) & ~isnan(pdff);
            udff = udff(valid_rows);
            pdff = pdff(valid_rows);
            labels = pdff_labels{g};
            
            % Initialize bootstrap AUC array
            bootstrapAucs{g} = zeros(nBoot, 1);
            
            % Bootstrap sampling
            for i = 1:nBoot
                sampleIndices = randsample(length(udff), length(udff), true);
                if length(unique(labels(sampleIndices))) > 1
                    [~, ~, ~, bootstrapAucs{g}(i)] = perfcurve(labels(sampleIndices), udff(sampleIndices), 1);
                else
                    bootstrapAucs{g}(i) = NaN;  % If only one class, set to NaN
                end
            end
            bootstrapAucs{g} = bootstrapAucs{g}(~isnan(bootstrapAucs{g}));  % Remove NaNs
        end
        
        % Calculate pairwise differences in AUCs between all groups
        bootstrapDiffs = [];
        for g1 = 1:nGroups-1
            for g2 = g1+1:nGroups
                minLen = min(length(bootstrapAucs{g1}), length(bootstrapAucs{g2}));
                bootstrapDiff = bootstrapAucs{g1}(1:minLen) - bootstrapAucs{g2}(1:minLen);
                bootstrapDiffs = [bootstrapDiffs; bootstrapDiff];  % Collect pairwise differences
            end
        end
        
        % Calculate the mean and standard deviation of the differences
        meanDiff = mean(bootstrapDiffs);
        stdDiff = std(bootstrapDiffs);
        
        % Calculate the z-score and p-value
        z = meanDiff / stdDiff;
        pValues(target) = 2 * normcdf(-abs(z));
    end
    
    % Return the results
    params.Auc = Auc;
    params.pValues = pValues;
    params.Np = Np;
    params.Nn = Nn;
end
