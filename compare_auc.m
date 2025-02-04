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

function [params] = compare_auc(udff1, pdff1, udff2, pdff2, pdff_thresholds)

    % Create a logical index for rows without NaN in either variable
    valid_rows1 = ~isnan(udff1) & ~isnan(pdff1);
    valid_rows2 = ~isnan(udff2) & ~isnan(pdff2);

    % Use the logical index to filter out rows with NaN
    udff1 = udff1(valid_rows1);
    pdff1 = pdff1(valid_rows1);
    udff2 = udff2(valid_rows2);
    pdff2 = pdff2(valid_rows2);

    nBoot = 1000;  

    % Initialize arrays to store results
    Auc1 = zeros(length(pdff_thresholds), 3);
    Auc2 = zeros(length(pdff_thresholds), 3);
    pValues = zeros(length(pdff_thresholds), 1);

    for target = 1:length(pdff_thresholds)
        pdff_target = pdff_thresholds(target);
        pdff_labels1 = pdff1 > pdff_target;
        pdff_labels2 = pdff2 > pdff_target;
        Np1(target) = sum(pdff_labels1);
        Nn1(target) = length(pdff_labels1) - Np1(target);
        Np2(target) = sum(pdff_labels2);
        Nn2(target) = length(pdff_labels2) - Np2(target);


        [~, ~, ~, Auc1temp] = perfcurve(pdff_labels1, udff1, 1, 'NBoot', nBoot);
        Auc1(target,:) = Auc1temp;

        [~, ~, ~, Auc2temp] = perfcurve(pdff_labels2, udff2, 1, 'NBoot', nBoot);
        Auc2(target,:) = Auc2temp;

        % Bootstrap AUCs
        bootstrapAuc1 = zeros(nBoot, 1);
        bootstrapAuc2 = zeros(nBoot, 1);

        for i = 1:nBoot
            sampleIndices1 = randsample(length(udff1), length(udff1), true);
            if length(unique(pdff_labels1(sampleIndices1))) > 1
                [~, ~, ~, bootstrapAuc1(i)] = perfcurve(pdff_labels1(sampleIndices1), udff1(sampleIndices1), 1);
            else
                bootstrapAuc1(i) = NaN; % If only one class, set to NaN
            end

            sampleIndices2 = randsample(length(udff2), length(udff2), true);
            if length(unique(pdff_labels2(sampleIndices2))) > 1
                [~, ~, ~, bootstrapAuc2(i)] = perfcurve(pdff_labels2(sampleIndices2), udff2(sampleIndices2), 1);
            else
                bootstrapAuc2(i) = NaN; % If only one class, set to NaN
            end
        end

        % Remove NaN values
        bootstrapAuc1 = bootstrapAuc1(~isnan(bootstrapAuc1));
        bootstrapAuc2 = bootstrapAuc2(~isnan(bootstrapAuc2));

        % Make sure both arrays have the same length
        minLen = min(length(bootstrapAuc1), length(bootstrapAuc2));
        bootstrapAuc1 = bootstrapAuc1(1:minLen);
        bootstrapAuc2 = bootstrapAuc2(1:minLen);


        % Calculate the difference in AUCs for each bootstrap sample
        bootstrapDiff = bootstrapAuc1 - bootstrapAuc2;

        % Calculate the mean and standard deviation of the differences
        meanDiff = mean(bootstrapDiff);
        stdDiff = std(bootstrapDiff);

        % Calculate the z-score
        z = meanDiff / stdDiff;

        % Calculate the p-value
        pValues(target) = 2 * normcdf(-abs(z));

    end

    % Return the results
    params.Auc1 = Auc1;
    params.Auc2 = Auc2;
    params.pValues = pValues;
    params.Np1 = Np1;
    params.Nn1 = Nn1;
    params.Np2 = Np2;
    params.Nn2 = Nn2;
end
