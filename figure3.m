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

pdff_thresholds = [5, 15, 20];           % Exploratory thresholds

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

% Update variables with filtered data
pdff = pdff(validRows);
udff9c2 = udff9c2(validRows);
udff5c1 = udff5c1(validRows);
udffdax = udffdax(validRows);
age = age(validRows);
sex = sex(validRows);
bmi = bmi(validRows);

% Initialize udffrandom as NaN array with the same length as the data
% Set the random seed for reproducibility
rng(135);  % You can choose any number for the seed
udffrandom = nan(size(pdff));
% Loop through each row and randomly select a non-NaN value from udffdax, udff5c1, and udff9c2
for i = 1:length(pdff)
    % Extract the available non-NaN values from udffdax, udff5c1, and udff9c2 for the current row
    values = [udffdax(i), udff5c1(i), udff9c2(i)];
    validValues = values(~isnan(values)); % Keep only non-NaN values
    
    % If there is exactly one valid value, assign it directly
    if length(validValues) == 1
        udffrandom(i) = validValues;
    % If there are multiple valid values, randomly pick one
    elseif ~isempty(validValues)
        udffrandom(i) = randsample(validValues, 1);
    end
end


% Define the groups based on pdff_thresholds2 (Exploratory)
groups2 = ones(size(pdff));  % Default group for pdff <= 5
groups2(pdff > pdff_thresholds(1) & pdff <= pdff_thresholds(2)) = 2;  % 5 < pdff <= 15
groups2(pdff > pdff_thresholds(2) & pdff <= pdff_thresholds(3)) = 3;  % 15 < pdff <= 20
groups2(pdff > pdff_thresholds(3)) = 4;  % pdff > 20

% Prepare for boxplot
udff_combined = [udffrandom(groups2 == 1); 
                 udffrandom(groups2 == 2); 
                 udffrandom(groups2 == 3); 
                 udffrandom(groups2 == 4)];

% Create group labels for boxplot
combined_groups = [repmat({'<=5%'}, sum(groups2 == 1), 1); 
                   repmat({'>5-15%'}, sum(groups2 == 2), 1); 
                   repmat({'>15-20%'}, sum(groups2 == 3), 1); 
                   repmat({'>20%'}, sum(groups2 == 4), 1)];

% Define custom colors for each category
colors1 = [
    0, 153/255, 153/255;        % #009999
    255/255, 210/255, 0;        % #ffd200
    236/255, 102/255, 2/255;    % #ec6602
    231/255, 0, 29/255;         % #e7001d
];

% Create figure for the boxplots
figure('Color', 'w'); % Set background color to white


% Plot boxplots for exploratory threshold sets
boxplot(udff_combined, combined_groups, 'Colors', 'k', 'Symbol', 'ko', 'OutlierSize', 4, 'Widths', 0.7);

% Calculate the number of observations in each group
n1 = sum(groups2 == 1);
n2 = sum(groups2 == 2);
n3 = sum(groups2 == 3);
n4 = sum(groups2 == 4);

set(gca, 'XTickLabel', {'≤5%', '>5-15%', '>15-20%', '>20%'});

line_width = 1.0; % Define the line width for consistency

% Apply custom colors to the boxplots
h1 = findobj(gca, 'Tag', 'Box');
for j = 1:length(h1)
    patch(get(h1(j), 'XData'), get(h1(j), 'YData'), colors1(end-j+1, :), 'FaceAlpha', 0.5); % Fill the box with color and set transparency
    set(h1(j), 'LineWidth', line_width, 'Color', 'k');
end

% Make whiskers (vertical lines) thicker
whiskers = findobj(gca, 'Tag', 'Whisker');
set(whiskers, 'LineWidth', line_width);

% Make caps (top and bottom horizontal lines) thicker
caps = findobj(gca, 'Tag', 'Cap');
set(caps, 'LineWidth', line_width);

% Make median lines thicker
medians = findobj(gca, 'Tag', 'Median');
set(medians, 'LineWidth', line_width);

% Make outlier outlines thicker
outliers = findobj(gca, 'Tag', 'Outliers');
set(outliers, 'MarkerEdgeColor', 'k', 'MarkerSize', 4, 'LineWidth', line_width);

% Customize the appearance of the plot
set(gca, 'FontSize', 12);
ylabel('UDFF (%)', 'FontSize', 12);
grid on;
box on;
xlabel('MRI-PDFF defined steatosis grades', 'FontSize', 12, 'HorizontalAlignment', 'center', 'Units', 'data', 'Position', [2.6, -3]);


% Add horizontal lines at 5, 10, 15, and 20
yline(5, '--k', '');
yline(10, '--k', '');
yline(15, '--k', '');
yline(20, '--k', '');

% Adjust plot aesthetics
xlim([0.5 7])
ylim([0 45])

% Turn the grid off
grid off;

% Add text for the specified ranges
text(4.5, 2.5, 'rule out ≥1 (minimal)', 'FontSize', 10, 'HorizontalAlignment', 'left');
text(4.5, 7.5, 'rule out ≥2 (minimal to mild)', 'FontSize', 10, 'HorizontalAlignment', 'left');
text(4.5, 12.5, 'rule out 3 (mild to moderate)', 'FontSize', 10, 'HorizontalAlignment', 'left');
text(4.5, 17.5, 'rule in ≥2 (moderate to severe)', 'FontSize', 10, 'HorizontalAlignment', 'left');
text(4.5, 22.5, 'rule in 3 (severe)', 'FontSize', 10, 'HorizontalAlignment', 'left');