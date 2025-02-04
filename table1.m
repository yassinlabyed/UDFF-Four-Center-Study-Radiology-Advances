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

% Age and bmi ............................................................
% Remove NaN values for age and BMI for overall, adults, and children
validAgeOverall = ~isnan(age); % Overall valid (non-NaN) age data
validBMIOverall = ~isnan(bmi); % Overall valid (non-NaN) BMI data

validAgeAdults = ~isnan(age) & age >= 18; % Adults with valid (non-NaN) age data
validAgeChildren = ~isnan(age) & age < 18; % Children with valid (non-NaN) age data

validBMIAdults = ~isnan(bmi) & age >= 18; % Adults with valid (non-NaN) BMI data
validBMIChildren = ~isnan(bmi) & age < 18; % Children with valid (non-NaN) BMI data

% Calculate N (number of participants)
N_overallAge = sum(validAgeOverall); % Overall N (non-NaN ages)
N_overallBMI = sum(validBMIOverall); % Overall N (non-NaN BMI)
N_adults = sum(validAgeAdults); % N for adults
N_children = sum(validAgeChildren); % N for children

% Age statistics (Overall, Adults, and Children)
meanAgeOverall = mean(age(validAgeOverall)); 
stdAgeOverall = std(age(validAgeOverall));

meanAgeAdults = mean(age(validAgeAdults)); 
stdAgeAdults = std(age(validAgeAdults));

meanAgeChildren = mean(age(validAgeChildren));
stdAgeChildren = std(age(validAgeChildren));

% BMI statistics (Overall, Adults, and Children)
meanBMIOverall = mean(bmi(validBMIOverall)); 
stdBMIOverall = std(bmi(validBMIOverall));

meanBMIAdults = mean(bmi(validBMIAdults)); 
stdBMIAdults = std(bmi(validBMIAdults));

meanBMIChildren = mean(bmi(validBMIChildren)); 
stdBMIChildren = std(bmi(validBMIChildren));

% Mann-Whitney U test (non-parametric test) for age comparison between adults and children
pValueAge = ranksum(age(validAgeAdults), age(validAgeChildren)); 

% Mann-Whitney U test (non-parametric test) for BMI comparison between adults and children
pValueBMI = ranksum(bmi(validBMIAdults), bmi(validBMIChildren));

% Display the N values
fprintf('Overall N (age): %d\n', N_overallAge);
fprintf('Overall N (BMI): %d\n', N_overallBMI);
fprintf('Adults N: %d\n', N_adults);
fprintf('Children N: %d\n', N_children);

% Display the age results
fprintf('Age (Overall): %.2f ± %.2f\n', meanAgeOverall, stdAgeOverall);
fprintf('Age (Adults): %.2f ± %.2f\n', meanAgeAdults, stdAgeAdults);
fprintf('Age (Children): %.2f ± %.2f\n', meanAgeChildren, stdAgeChildren);
fprintf('P-value (Age): %.4f\n', pValueAge);

% Display the BMI results
fprintf('BMI (Overall): %.2f ± %.2f\n', meanBMIOverall, stdBMIOverall);
fprintf('BMI (Adults): %.2f ± %.2f\n', meanBMIAdults, stdBMIAdults);
fprintf('BMI (Children): %.2f ± %.2f\n', meanBMIChildren, stdBMIChildren);
fprintf('P-value (BMI): %.4f\n', pValueBMI);

% pdff --------------------------------------------------------------------
% PDFF statistics ............................................................
% Remove NaN values for PDFF for overall, adults, and children
validPdffOverall = ~isnan(pdff); % Overall valid (non-NaN) PDFF data
validPdffAdults = ~isnan(pdff) & age >= 18; % Adults with valid (non-NaN) PDFF data
validPdffChildren = ~isnan(pdff) & age < 18; % Children with valid (non-NaN) PDFF data

% Calculate N (number of participants for PDFF)
N_overallPdff = sum(validPdffOverall); % Overall N (non-NaN PDFF)
N_adultsPdff = sum(validPdffAdults); % N for adults with valid PDFF
N_childrenPdff = sum(validPdffChildren); % N for children with valid PDFF

% PDFF statistics (Overall, Adults, and Children)
meanPdffOverall = mean(pdff(validPdffOverall)); 
stdPdffOverall = std(pdff(validPdffOverall));

meanPdffAdults = mean(pdff(validPdffAdults)); 
stdPdffAdults = std(pdff(validPdffAdults));

meanPdffChildren = mean(pdff(validPdffChildren)); 
stdPdffChildren = std(pdff(validPdffChildren));

% Mann-Whitney U test (non-parametric test) for PDFF comparison between adults and children
pValuePdff = ranksum(pdff(validPdffAdults), pdff(validPdffChildren));

% Display the N values for PDFF
fprintf('Overall N (PDFF): %d\n', N_overallPdff);
fprintf('Adults N (PDFF): %d\n', N_adultsPdff);
fprintf('Children N (PDFF): %d\n', N_childrenPdff);

% Display the PDFF results
fprintf('PDFF (Overall): %.2f ± %.2f\n', meanPdffOverall, stdPdffOverall);
fprintf('PDFF (Adults): %.2f ± %.2f\n', meanPdffAdults, stdPdffAdults);
fprintf('PDFF (Children): %.2f ± %.2f\n', meanPdffChildren, stdPdffChildren);
fprintf('P-value (PDFF): %.4f\n', pValuePdff);

% udff dax, 5c1, and 9c2...................................................
% Remove NaN values for UDFF DAX, 5C1, and 9C2 for overall, adults, and children
validOverallDAX = ~isnan(udffdax); % Overall valid UDFF DAX data
validAdultsDAX = age >= 18 & ~isnan(udffdax); % Adults with valid UDFF DAX data
validChildrenDAX = age < 18 & ~isnan(udffdax); % Children with valid UDFF DAX data

validOverall5C1 = ~isnan(udff5c1); % Overall valid UDFF 5C1 data
validAdults5C1 = age >= 18 & ~isnan(udff5c1); % Adults with valid UDFF 5C1 data
validChildren5C1 = age < 18 & ~isnan(udff5c1); % Children with valid UDFF 5C1 data

validOverall9C2 = ~isnan(udff9c2); % Overall valid UDFF 9C2 data
validAdults9C2 = age >= 18 & ~isnan(udff9c2); % Adults with valid UDFF 9C2 data
validChildren9C2 = age < 18 & ~isnan(udff9c2); % Children with valid UDFF 9C2 data

% Calculate N for overall, adults, and children (UDFF DAX, 5C1, and 9C2)
N_overallDAX = sum(validOverallDAX); % N for overall with valid UDFF DAX
N_adultsDAX = sum(validAdultsDAX); % N for adults with valid UDFF DAX
N_childrenDAX = sum(validChildrenDAX); % N for children with valid UDFF DAX

N_overall5C1 = sum(validOverall5C1); % N for overall with valid UDFF 5C1
N_adults5C1 = sum(validAdults5C1); % N for adults with valid UDFF 5C1
N_children5C1 = sum(validChildren5C1); % N for children with valid UDFF 5C1

N_overall9C2 = sum(validOverall9C2); % N for overall with valid UDFF 9C2
N_adults9C2 = sum(validAdults9C2); % N for adults with valid UDFF 9C2
N_children9C2 = sum(validChildren9C2); % N for children with valid UDFF 9C2

% UDFF DAX statistics for overall, adults, and children
meanUDFFDAXOverall = mean(udffdax(validOverallDAX)); 
stdUDFFDAXOverall = std(udffdax(validOverallDAX));

meanUDFFDAXAdults = mean(udffdax(validAdultsDAX)); 
stdUDFFDAXAdults = std(udffdax(validAdultsDAX));

meanUDFFDAXChildren = mean(udffdax(validChildrenDAX)); 
stdUDFFDAXChildren = std(udffdax(validChildrenDAX));

% UDFF 5C1 statistics for overall, adults, and children
meanUDFF5C1Overall = mean(udff5c1(validOverall5C1)); 
stdUDFF5C1Overall = std(udff5c1(validOverall5C1));

meanUDFF5C1Adults = mean(udff5c1(validAdults5C1)); 
stdUDFF5C1Adults = std(udff5c1(validAdults5C1));

meanUDFF5C1Children = mean(udff5c1(validChildren5C1)); 
stdUDFF5C1Children = std(udff5c1(validChildren5C1));

% UDFF 9C2 statistics for overall, adults, and children
meanUDFF9C2Overall = mean(udff9c2(validOverall9C2)); 
stdUDFF9C2Overall = std(udff9c2(validOverall9C2));

meanUDFF9C2Adults = mean(udff9c2(validAdults9C2)); 
stdUDFF9C2Adults = std(udff9c2(validAdults9C2));

meanUDFF9C2Children = mean(udff9c2(validChildren9C2)); 
stdUDFF9C2Children = std(udff9c2(validChildren9C2));

% Mann-Whitney U test (non-parametric test) for comparing adults and children
pValueDAX = ranksum(udffdax(validAdultsDAX), udffdax(validChildrenDAX)); % P-value for UDFF DAX
pValue5C1 = ranksum(udff5c1(validAdults5C1), udff5c1(validChildren5C1)); % P-value for UDFF 5C1
pValue9C2 = ranksum(udff9c2(validAdults9C2), udff9c2(validChildren9C2)); % P-value for UDFF 9C2

% Display N values and statistics for UDFF DAX, 5C1, and 9C2 for overall, adults, and children
fprintf('Overall N (UDFF DAX): %d\n', N_overallDAX);
fprintf('Adults N (UDFF DAX): %d\n', N_adultsDAX);
fprintf('Children N (UDFF DAX): %d\n', N_childrenDAX);
fprintf('UDFF DAX (Overall): %.2f ± %.2f\n', meanUDFFDAXOverall, stdUDFFDAXOverall);
fprintf('UDFF DAX (Adults): %.2f ± %.2f\n', meanUDFFDAXAdults, stdUDFFDAXAdults);
fprintf('UDFF DAX (Children): %.2f ± %.2f\n', meanUDFFDAXChildren, stdUDFFDAXChildren);
fprintf('P-value (UDFF DAX): %.4f\n', pValueDAX);

fprintf('Overall N (UDFF 5C1): %d\n', N_overall5C1);
fprintf('Adults N (UDFF 5C1): %d\n', N_adults5C1);
fprintf('Children N (UDFF 5C1): %d\n', N_children5C1);
fprintf('UDFF 5C1 (Overall): %.2f ± %.2f\n', meanUDFF5C1Overall, stdUDFF5C1Overall);
fprintf('UDFF 5C1 (Adults): %.2f ± %.2f\n', meanUDFF5C1Adults, stdUDFF5C1Adults);
fprintf('UDFF 5C1 (Children): %.2f ± %.2f\n', meanUDFF5C1Children, stdUDFF5C1Children);
fprintf('P-value (UDFF 5C1): %.4f\n', pValue5C1);

fprintf('Overall N (UDFF 9C2): %d\n', N_overall9C2);
fprintf('Adults N (UDFF 9C2): %d\n', N_adults9C2);
fprintf('Children N (UDFF 9C2): %d\n', N_children9C2);
fprintf('UDFF 9C2 (Overall): %.2f ± %.2f\n', meanUDFF9C2Overall, stdUDFF9C2Overall);
fprintf('UDFF 9C2 (Adults): %.2f ± %.2f\n', meanUDFF9C2Adults, stdUDFF9C2Adults);
fprintf('UDFF 9C2 (Children): %.2f ± %.2f\n', meanUDFF9C2Children, stdUDFF9C2Children);
fprintf('P-value (UDFF 9C2): %.4f\n', pValue9C2);

% sex male femle ..........................................................
% Define logical arrays for adults and children
validAdults = age >= 18; % All adults in the dataset
validChildren = age < 18; % All children in the dataset

% Calculate total numbers for each group
N_totalOverall = length(age); % Total number of participants
N_totalAdults = sum(validAdults); % Total number of adults
N_totalChildren = sum(validChildren); % Total number of children

% Calculate the number of males and females in each group
N_maleOverall = sum(sex == 'M'); % Total number of males overall
N_femaleOverall = sum(sex == 'F'); % Total number of females overall

N_maleAdults = sum(validAdults & sex == 'M'); % Number of adult males
N_femaleAdults = sum(validAdults & sex == 'F'); % Number of adult females

N_maleChildren = sum(validChildren & sex == 'M'); % Number of male children
N_femaleChildren = sum(validChildren & sex == 'F'); % Number of female children

% Calculate percentages
percent_maleOverall = (N_maleOverall / N_totalOverall) * 100;
percent_femaleOverall = (N_femaleOverall / N_totalOverall) * 100;

percent_maleAdults = (N_maleAdults / N_totalAdults) * 100;
percent_femaleAdults = (N_femaleAdults / N_totalAdults) * 100;

percent_maleChildren = (N_maleChildren / N_totalChildren) * 100;
percent_femaleChildren = (N_femaleChildren / N_totalChildren) * 100;

% Create arrays for crosstab
group = [repmat('Adult', N_totalAdults, 1); repmat('Child', N_totalChildren, 1)]; % Adult or Child group
sexGroup = [repmat(sex(validAdults), 1); repmat(sex(validChildren), 1)]; % Male or Female group

% Create contingency table using crosstab
[tbl, chi2stat, pValue] = crosstab(group, sexGroup);

% Display results for males and females with p-value
fprintf('Overall Males: %.1f%% (%d/%d)\n', percent_maleOverall, N_maleOverall, N_totalOverall);
fprintf('Overall Females: %.1f%% (%d/%d)\n', percent_femaleOverall, N_femaleOverall, N_totalOverall);

fprintf('\nAdult Males: %.1f%% (%d/%d)\n', percent_maleAdults, N_maleAdults, N_totalAdults);
fprintf('Adult Females: %.1f%% (%d/%d)\n', percent_femaleAdults, N_femaleAdults, N_totalAdults);

fprintf('\nChildren Males: %.1f%% (%d/%d)\n', percent_maleChildren, N_maleChildren, N_totalChildren);
fprintf('Children Females: %.1f%% (%d/%d)\n', percent_femaleChildren, N_femaleChildren, N_totalChildren);

% Display Chi-squared test result
fprintf('\nChi-squared test p-value: %.4f\n', pValue);

% transdcuer data availabiltiy ...........................................
% Define logical arrays for adults and children
validAdults = age >= 18; % All adults in the dataset
validChildren = age < 18; % All children in the dataset

% Data availability for each transducer
daxGroupAdults = ~isnan(udffdax(validAdults)); % Adult data availability for DAX
daxGroupChildren = ~isnan(udffdax(validChildren)); % Children data availability for DAX

c5GroupAdults = ~isnan(udff5c1(validAdults)); % Adult data availability for 5C1
c5GroupChildren = ~isnan(udff5c1(validChildren)); % Children data availability for 5C1

c9GroupAdults = ~isnan(udff9c2(validAdults)); % Adult data availability for 9C2
c9GroupChildren = ~isnan(udff9c2(validChildren)); % Children data availability for 9C2

% Create a combined array for all transducers (DAX, 5C1, 9C2)
group = [repmat('Adult', sum(validAdults), 1); repmat('Child', sum(validChildren), 1)];
dataAvailability = [daxGroupAdults; daxGroupChildren; c5GroupAdults; c5GroupChildren; c9GroupAdults; c9GroupChildren];

% Create transducer labels for grouping (DAX, 5C1, 9C2)
transducerLabels = [repmat('DAX', sum(validAdults) + sum(validChildren), 1); ...
                    repmat('5C1', sum(validAdults) + sum(validChildren), 1); ...
                    repmat('9C2', sum(validAdults) + sum(validChildren), 1)];

% Combine the group and transducer labels
groupAll = [group; group; group];

% Perform Chi-squared test using crosstab for all transducers
[tbl, chi2stat, pValue] = crosstab(groupAll, transducerLabels, dataAvailability);

% Display results for each transducer data availability
fprintf('DAX Data Availability:\n');
fprintf('Adults: %d/%d\n', sum(daxGroupAdults), sum(validAdults));
fprintf('Children: %d/%d\n', sum(daxGroupChildren), sum(validChildren));

fprintf('\n5C1 Data Availability:\n');
fprintf('Adults: %d/%d\n', sum(c5GroupAdults), sum(validAdults));
fprintf('Children: %d/%d\n', sum(c5GroupChildren), sum(validChildren));

fprintf('\n9C2 Data Availability:\n');
fprintf('Adults: %d/%d\n', sum(c9GroupAdults), sum(validAdults));
fprintf('Children: %d/%d\n', sum(c9GroupChildren), sum(validChildren));

% Display Chi-squared test result
fprintf('\nChi-squared test p-value: %.4f\n', pValue);

% historical steatosis grade ..............................................
% Define logical arrays for adults and children
validAdults = age >= 18; % All adults in the dataset
validChildren = age < 18; % All children in the dataset

% Define steatosis grades based on MRI-PDFF
S0 = pdff <= 5.75; % Grade S0: MRI-PDFF ≤ 5.75%
S1 = pdff > 5.75 & pdff <= 15.50; % Grade S1: 5.75% < MRI-PDFF ≤ 15.50%
S2 = pdff > 15.50 & pdff <= 21.35; % Grade S2: 15.50% < MRI-PDFF ≤ 21.35%
S3 = pdff > 21.35; % Grade S3: MRI-PDFF > 21.35%

% Create a categorical variable for steatosis grade
steatosisGrade = categorical(S0 .* 0 + S1 .* 1 + S2 .* 2 + S3 .* 3, [0 1 2 3], {'S0', 'S1', 'S2', 'S3'});

% Separate the steatosis grade data for overall, adults, and children
steatosisOverall = steatosisGrade; % Steatosis grades for overall
steatosisAdults = steatosisGrade(validAdults); % Steatosis grades for adults
steatosisChildren = steatosisGrade(validChildren); % Steatosis grades for children

% Create arrays for crosstab comparison
group = [repmat('Adult', sum(validAdults), 1); repmat('Child', sum(validChildren), 1)];
steatosisData = [steatosisAdults; steatosisChildren];

% Perform the Chi-squared test using crosstab for steatosis grade distribution
[tbl, chi2stat, pValue] = crosstab(group, steatosisData);

% Calculate the number of participants in each steatosis grade
N_S0Overall = sum(steatosisOverall == 'S0');
N_S1Overall = sum(steatosisOverall == 'S1');
N_S2Overall = sum(steatosisOverall == 'S2');
N_S3Overall = sum(steatosisOverall == 'S3');

N_S0Adults = sum(steatosisAdults == 'S0');
N_S1Adults = sum(steatosisAdults == 'S1');
N_S2Adults = sum(steatosisAdults == 'S2');
N_S3Adults = sum(steatosisAdults == 'S3');

N_S0Children = sum(steatosisChildren == 'S0');
N_S1Children = sum(steatosisChildren == 'S1');
N_S2Children = sum(steatosisChildren == 'S2');
N_S3Children = sum(steatosisChildren == 'S3');

% Total number of overall participants, adults, and children
N_totalOverall = length(steatosisOverall);
N_totalAdults = sum(validAdults);
N_totalChildren = sum(validChildren);

% Calculate percentages for overall, adults, and children for each steatosis grade
percent_S0Overall = (N_S0Overall / N_totalOverall) * 100;
percent_S1Overall = (N_S1Overall / N_totalOverall) * 100;
percent_S2Overall = (N_S2Overall / N_totalOverall) * 100;
percent_S3Overall = (N_S3Overall / N_totalOverall) * 100;

percent_S0Adults = (N_S0Adults / N_totalAdults) * 100;
percent_S1Adults = (N_S1Adults / N_totalAdults) * 100;
percent_S2Adults = (N_S2Adults / N_totalAdults) * 100;
percent_S3Adults = (N_S3Adults / N_totalAdults) * 100;

percent_S0Children = (N_S0Children / N_totalChildren) * 100;
percent_S1Children = (N_S1Children / N_totalChildren) * 100;
percent_S2Children = (N_S2Children / N_totalChildren) * 100;
percent_S3Children = (N_S3Children / N_totalChildren) * 100;

% Display the results for steatosis grades with percentage (numerator/denominator)
fprintf('Steatosis Grade S0:\n');
fprintf('Overall: %.1f%% (%d/%d)\n', percent_S0Overall, N_S0Overall, N_totalOverall);
fprintf('Adults: %.1f%% (%d/%d)\n', percent_S0Adults, N_S0Adults, N_totalAdults);
fprintf('Children: %.1f%% (%d/%d)\n', percent_S0Children, N_S0Children, N_totalChildren);

fprintf('\nSteatosis Grade S1:\n');
fprintf('Overall: %.1f%% (%d/%d)\n', percent_S1Overall, N_S1Overall, N_totalOverall);
fprintf('Adults: %.1f%% (%d/%d)\n', percent_S1Adults, N_S1Adults, N_totalAdults);
fprintf('Children: %.1f%% (%d/%d)\n', percent_S1Children, N_S1Children, N_totalChildren);

fprintf('\nSteatosis Grade S2:\n');
fprintf('Overall: %.1f%% (%d/%d)\n', percent_S2Overall, N_S2Overall, N_totalOverall);
fprintf('Adults: %.1f%% (%d/%d)\n', percent_S2Adults, N_S2Adults, N_totalAdults);
fprintf('Children: %.1f%% (%d/%d)\n', percent_S2Children, N_S2Children, N_totalChildren);

fprintf('\nSteatosis Grade S3:\n');
fprintf('Overall: %.1f%% (%d/%d)\n', percent_S3Overall, N_S3Overall, N_totalOverall);
fprintf('Adults: %.1f%% (%d/%d)\n', percent_S3Adults, N_S3Adults, N_totalAdults);
fprintf('Children: %.1f%% (%d/%d)\n', percent_S3Children, N_S3Children, N_totalChildren);

% Display the Chi-squared test result
fprintf('\nChi-squared test p-value for steatosis grade distribution: %.4f\n', pValue);

% pre-defined steatosis grade ..............................................
% Define logical arrays for adults and children
validAdults = age >= 18; % All adults in the dataset
validChildren = age < 18; % All children in the dataset

% Define steatosis grades based on MRI-PDFF
S0 = pdff <= 5.; % Grade S0: MRI-PDFF ≤ 5.%
S1 = pdff > 5. & pdff <= 15.; % Grade S1: 5.% < MRI-PDFF ≤ 15.%
S2 = pdff > 15. & pdff <= 20; % Grade S2: 15.% < MRI-PDFF ≤ 20%
S3 = pdff > 20; % Grade S3: MRI-PDFF > 20%

% Create a categorical variable for steatosis grade
steatosisGrade = categorical(S0 .* 0 + S1 .* 1 + S2 .* 2 + S3 .* 3, [0 1 2 3], {'S0', 'S1', 'S2', 'S3'});

% Separate the steatosis grade data for overall, adults, and children
steatosisOverall = steatosisGrade; % Steatosis grades for overall
steatosisAdults = steatosisGrade(validAdults); % Steatosis grades for adults
steatosisChildren = steatosisGrade(validChildren); % Steatosis grades for children

% Create arrays for crosstab comparison
group = [repmat('Adult', sum(validAdults), 1); repmat('Child', sum(validChildren), 1)];
steatosisData = [steatosisAdults; steatosisChildren];

% Perform the Chi-squared test using crosstab for steatosis grade distribution
[tbl, chi2stat, pValue] = crosstab(group, steatosisData);

% Calculate the number of participants in each steatosis grade
N_S0Overall = sum(steatosisOverall == 'S0');
N_S1Overall = sum(steatosisOverall == 'S1');
N_S2Overall = sum(steatosisOverall == 'S2');
N_S3Overall = sum(steatosisOverall == 'S3');

N_S0Adults = sum(steatosisAdults == 'S0');
N_S1Adults = sum(steatosisAdults == 'S1');
N_S2Adults = sum(steatosisAdults == 'S2');
N_S3Adults = sum(steatosisAdults == 'S3');

N_S0Children = sum(steatosisChildren == 'S0');
N_S1Children = sum(steatosisChildren == 'S1');
N_S2Children = sum(steatosisChildren == 'S2');
N_S3Children = sum(steatosisChildren == 'S3');

% Total number of overall participants, adults, and children
N_totalOverall = length(steatosisOverall);
N_totalAdults = sum(validAdults);
N_totalChildren = sum(validChildren);

% Calculate percentages for overall, adults, and children for each steatosis grade
percent_S0Overall = (N_S0Overall / N_totalOverall) * 100;
percent_S1Overall = (N_S1Overall / N_totalOverall) * 100;
percent_S2Overall = (N_S2Overall / N_totalOverall) * 100;
percent_S3Overall = (N_S3Overall / N_totalOverall) * 100;

percent_S0Adults = (N_S0Adults / N_totalAdults) * 100;
percent_S1Adults = (N_S1Adults / N_totalAdults) * 100;
percent_S2Adults = (N_S2Adults / N_totalAdults) * 100;
percent_S3Adults = (N_S3Adults / N_totalAdults) * 100;

percent_S0Children = (N_S0Children / N_totalChildren) * 100;
percent_S1Children = (N_S1Children / N_totalChildren) * 100;
percent_S2Children = (N_S2Children / N_totalChildren) * 100;
percent_S3Children = (N_S3Children / N_totalChildren) * 100;

% Display the results for steatosis grades with percentage (numerator/denominator)
fprintf('Steatosis Grade S0:\n');
fprintf('Overall: %.1f%% (%d/%d)\n', percent_S0Overall, N_S0Overall, N_totalOverall);
fprintf('Adults: %.1f%% (%d/%d)\n', percent_S0Adults, N_S0Adults, N_totalAdults);
fprintf('Children: %.1f%% (%d/%d)\n', percent_S0Children, N_S0Children, N_totalChildren);

fprintf('\nSteatosis Grade S1:\n');
fprintf('Overall: %.1f%% (%d/%d)\n', percent_S1Overall, N_S1Overall, N_totalOverall);
fprintf('Adults: %.1f%% (%d/%d)\n', percent_S1Adults, N_S1Adults, N_totalAdults);
fprintf('Children: %.1f%% (%d/%d)\n', percent_S1Children, N_S1Children, N_totalChildren);

fprintf('\nSteatosis Grade S2:\n');
fprintf('Overall: %.1f%% (%d/%d)\n', percent_S2Overall, N_S2Overall, N_totalOverall);
fprintf('Adults: %.1f%% (%d/%d)\n', percent_S2Adults, N_S2Adults, N_totalAdults);
fprintf('Children: %.1f%% (%d/%d)\n', percent_S2Children, N_S2Children, N_totalChildren);

fprintf('\nSteatosis Grade S3:\n');
fprintf('Overall: %.1f%% (%d/%d)\n', percent_S3Overall, N_S3Overall, N_totalOverall);
fprintf('Adults: %.1f%% (%d/%d)\n', percent_S3Adults, N_S3Adults, N_totalAdults);
fprintf('Children: %.1f%% (%d/%d)\n', percent_S3Children, N_S3Children, N_totalChildren);

% Display the Chi-squared test result
fprintf('\nChi-squared test p-value for steatosis grade distribution: %.4f\n', pValue);
