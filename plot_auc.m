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

function [params] = plot_auc(udff, pdff,pdff_thresholds)

    cutoffs = [5 10 15];
%     cutoffs = [5 15 20];  % pick only last two

    % Create a logical index for rows without NaN in either variable
    valid_rows = ~isnan(udff) & ~isnan(pdff);

    % Use the logical index to filter out rows with NaN
    udff = udff(valid_rows);
    pdff = pdff(valid_rows);

    nBoot = 1000;  % Number of bootstrap samples
    
    for target = 1:length(pdff_thresholds)
        pdff_target = pdff_thresholds(target);
        pdff_labels = pdff > pdff_target;
        Np(target) = sum(pdff_labels);
        Nn(target) = length(pdff_labels) - Np(target);
        thresholds = linspace(0,max(udff),nBoot);
        [FalsePositiveRate, TruePositiveRate, udff_thresholds, Auc1] = perfcurve(pdff_labels, udff, 1, 'NBoot', nBoot, 'TVals',thresholds);
        
        FPR(target,:) = FalsePositiveRate(:,1);
        TPR(target,:) = TruePositiveRate(:,1);
        Aucs(target) = Auc1(1);
        AucsL(target) = Auc1(2);
        AucsR(target) = Auc1(3);
        
        results = calc_metrics(udff,pdff_labels, cutoffs(target));
        sens(target) = results(1);
        spec(target) = results(2);
        ppv(target) = results(3);
        npv(target) = results(4);
        accuracy(target) = results(5);

        % Bootstrap confidence intervals
        bootStats = bootstrp(nBoot, @(bootIdx) calc_metrics(udff(bootIdx), pdff_labels(bootIdx), cutoffs(target)), 1:length(udff));
        CI_sens(target,:) = prctile(bootStats(:,1), [2.5 97.5]);
        CI_spec(target,:) = prctile(bootStats(:,2), [2.5 97.5]);
        CI_ppv(target,:) = prctile(bootStats(:,3), [2.5 97.5]);
        CI_npv(target,:) = prctile(bootStats(:,4), [2.5 97.5]);
        CI_accuracy(target,:) = prctile(bootStats(:,5), [2.5 97.5]);
    end

    params.auc = Aucs;
    params.aucL = AucsL;
    params.aucR = AucsR;
    params.np = Np;
    params.nn = Nn;
    params.sens = sens;
    params.spec = spec;
    params.ppv = ppv;
    params.npv = npv;
    params.accuracy = accuracy;
    params.CI_sens = CI_sens;
    params.CI_spec = CI_spec;
    params.CI_ppv = CI_ppv;
    params.CI_npv = CI_npv;
    params.CI_accuracy = CI_accuracy;


    % Ensure data is cell arrays of strings
    Nn_vs_Np = cellstr(strcat(num2str(Nn'), " vs ", num2str(Np')));
    AUC_95_CI = cellstr(strcat(num2str(round(Aucs', 2)), " (", num2str(round(AucsL', 2)), " - ", num2str(round(AucsR', 2)), ")"));
    Sensitivity_95_CI = cellstr(strcat(num2str(round(sens', 2)), " (", num2str(round(CI_sens(:,1), 2)), " - ", num2str(round(CI_sens(:,2), 2)), ")"));
    Specificity_95_CI = cellstr(strcat(num2str(round(spec', 2)), " (", num2str(round(CI_spec(:,1), 2)), " - ", num2str(round(CI_spec(:,2), 2)), ")"));
    PPV_95_CI = cellstr(strcat(num2str(round(ppv', 2)), " (", num2str(round(CI_ppv(:,1), 2)), " - ", num2str(round(CI_ppv(:,2), 2)), ")"));
    NPV_95_CI = cellstr(strcat(num2str(round(npv', 2)), " (", num2str(round(CI_npv(:,1), 2)), " - ", num2str(round(CI_npv(:,2), 2)), ")"));
    Accuracy_95_CI = cellstr(strcat(num2str(round(accuracy', 2)), " (", num2str(round(CI_accuracy(:,1), 2)), " - ", num2str(round(CI_accuracy(:,2), 2)), ")"));

    % Create a table for the results
    resultsTable = table(...
        Nn_vs_Np, ...
        AUC_95_CI, ...
        Sensitivity_95_CI, ...
        Specificity_95_CI, ...
        PPV_95_CI, ...
        NPV_95_CI, ...
        Accuracy_95_CI, ...
        'VariableNames', {'Nn vs Np', 'AUC (95% CI)', 'Sensitivity (95% CI)', 'Specificity (95% CI)', 'PPV (95% CI)', 'NPV (95% CI)', 'Accuracy (95% CI)'});
    
    % Save the table to an Excel file
    writetable(resultsTable, 'stats.xlsx');
    resultsTable

    % Define custom colors for each category
    colors = [
        0, 153/255, 153/255;        % #009999
        255/255, 210/255, 0;        % #ffd200
        236/255, 102/255, 2/255;    % #ec6602
        231/255, 0, 29/255;         % #e7001d
    ];
    figure, clf; hold on
    for target = 1:length(pdff_thresholds)
        plot(FPR(target,:), TPR(target,:), 'LineWidth', 2,'color',colors(target,:));
        xlabel('False Positive Rate (FPR)');
        ylabel('True Positive Rate (TPR)');
        grid on;
    end
    legend(['0 vs \geq1, AUC = ' sprintf('%.2f (%.2f\x2013%.2f)', Aucs(1), AucsL(1), AucsR(1))],...
        ['\leq1  vs \geq2, AUC = ' sprintf('%.2f (%.2f\x2013%.2f)', Aucs(2), AucsL(2), AucsR(2))],...
        ['\leq1 vs 3, AUC = ' sprintf('%.2f (%.2f\x2013%.2f)', Aucs(3), AucsL(3), AucsR(3))], 'location', 'southeast');
end

function metrics = calc_metrics(udff, pdff_labels, cutoff)
    predictions = udff >= cutoff;
    TP = sum(predictions == 1 & pdff_labels == 1);
    FP = sum(predictions == 1 & pdff_labels == 0);
    FN = sum(predictions == 0 & pdff_labels == 1);
    TN = sum(predictions == 0 & pdff_labels == 0);
    
    sens = TP / (TP + FN);
    spec = TN / (TN + FP);
    ppv = TP / (TP + FP);
    npv = TN / (TN + FN);
    accuracy = (TP + TN) / (TP + FP + TN + FN);
    
    metrics = [sens, spec, ppv, npv, accuracy];
end
