function NMRdataAnalysis(files,sampleConcentration,bool)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
fullpaths = fullfile({files.folder}, {files.name});
function file_import = importfile(filename, dataLines)
%IMPORTFILE Import data from a text file
%  file_import = IMPORTFILE(FILENAME) reads data from text file FILENAME
%  for the default selection.  Returns the data as a table.
%
%  file_import = IMPORTFILE(FILE, DATALINES) reads data for the specified
%  row interval(s) of text file FILENAME. Specify DATALINES as a
%  positive scalar integer or a N-by-2 array of positive scalar integers
%  for dis-contiguous row intervals.
%
%  Example:
%  file_import = importfile("G:\My Drive\1. Projects\PHYS-559 Graduate Laboratory (Spring 2023)\NMR Project\Data\0.0102M CuSO4\20230206-0001-3.1us.csv", [4, Inf]);
%
%  See also READTABLE.
%
% Auto-generated by MATLAB on 07-Feb-2023 08:49:10

%% Input handling

% If dataLines is not specified, define defaults
if nargin < 2
    dataLines = [4, Inf];
end

%% Setup the Import Options and import the data
opts = delimitedTextImportOptions("NumVariables", 2);

% Specify range and delimiter
opts.DataLines = dataLines;
opts.Delimiter = ",";

% Specify column names and types
opts.VariableNames = ["Time", "Voltage"];
opts.VariableTypes = ["double", "double"];

% Specify file level properties
opts.ImportErrorRule = "omitrow";
opts.MissingRule = "omitrow";
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";

% Import the data
file_import = readtable(filename, opts);

end
pulse_seperation = [];
spinEchoAmp = [];
% Plot each file
for i = 1 : length(fullpaths)
    %create temp variables
    x = importfile(fullpaths{i}).Time;
    y = importfile(fullpaths{i}).Voltage;
    local_max = islocalmax(y,'SamplePoints',x,'MinProminence',0.5,'FlatSelection','first','MinSeparation',0.1);
    max_x1 = x(local_max);
    max_y1 = y(local_max);
    pulse_seperation(i) = max_x1(2)-max_x1(1);
    spinEchoAmp(i) = max_y1(3);
%     figure;
%     plot(x,y,x(local_max),y(local_max),'r*')
%     ylim([0 11])
%     xlabel("Time (ms)")
%     ylabel("Voltage (V)")
% %     title(str, 'Interpreter',"latex")
end

figure;
plot(pulse_seperation,spinEchoAmp, '.')
xlabel("Pulse Seperation (ms)")
ylabel("Spin Echo Amplitude")
title("Spin Echo Amplitude as a function of Pulse Seperation for " + sampleConcentration + " CuSO_4")

logSpinamp = log(spinEchoAmp);
figure;
plot(pulse_seperation,log(spinEchoAmp), '.')
xlabel("Pulse Seperation (ms)")
ylabel("log(Spin Echo Amplitude)")
title("Spin Echo Amplitude as a function of Pulse Seperation for " + sampleConcentration + " CuSO_4")
function [fitresult, gof] = linearFit(pulse_seperation, logSpinamp)
%CREATEFIT1(PULSE_SEPERATION,LOGSPINAMP)
%  Create a fit.
%
%  Data for 'Linear' fit:
%      X Input: pulse_seperation
%      Y Output: logSpinamp
%  Output:
%      fitresult : a fit object representing the fit.
%      gof : structure with goodness-of fit info.
%
%  See also FIT, CFIT, SFIT.

%  Auto-generated by MATLAB on 10-Feb-2023 07:19:35


%% Fit: 'Linear Fit'.
[xData, yData] = prepareCurveData( pulse_seperation, logSpinamp );

% Set up fittype and options.
ft = fittype( 'poly1' );
excludedPoints = excludedata( xData, yData, 'Indices', 5 );
opts = fitoptions( 'Method', 'LinearLeastSquares' );
opts.Normalize = 'on';
opts.Robust = 'LAR';
opts.Exclude = excludedPoints;

% Fit model to data.
[fitresult, gof] = fit( xData, yData, ft, opts );

% Plot fit with data.
figure( 'Name', 'Linear Fit' );
h = plot( fitresult, xData, yData, excludedPoints );
legend( h, 'logSpinamp vs. pulse_seperation', 'Excluded logSpinamp vs. pulse_seperation', 'y = mx + b', 'Location', 'NorthEast', 'Interpreter', 'none' );
% Label axes
xlabel('Pulse Seperation (ms)' );
ylabel('log(Spin Echo Amplitude)');
title("log(Spin Echo Amplitude) as a function of Pulse Seperation with exponential fit for " + sampleConcentration + " CuSO_4")
grid on

end
function [fitresult, gof] = exponentialFit(pulse_seperation, spinEchoAmp)
%CREATEFIT(PULSE_SEPERATION,SPINECHOAMP)
%  Create a fit.
%
%  Data for 'Exponential Fit' fit:
%      X Input: pulse_seperation
%      Y Output: spinEchoAmp
%  Output:
%      fitresult : a fit object representing the fit.
%      gof : structure with goodness-of fit info.
%
%  See also FIT, CFIT, SFIT.

%  Auto-generated by MATLAB on 10-Feb-2023 07:19:02


%% Fit: 'Exponential Fit'.
[xData, yData] = prepareCurveData( pulse_seperation, spinEchoAmp );

% Set up fittype and options.
ft = fittype( 'a*exp(-t/t_2)', 'independent', 'x', 'dependent', 'y' );
excludedPoints = excludedata( xData, yData, 'Indices', 5 );
opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
opts.Display = 'Off';
opts.StartPoint = [0.751267059305653 0.699076722656686];
opts.Exclude = excludedPoints;

% Fit model to data.
[fitresult, gof] = fit( xData, yData, ft, opts );

% Plot fit with data.
figure( 'Name', 'untitled fit 2' );
h = plot( fitresult, xData, yData, excludedPoints );
legend( h, 'spinEchoAmp vs. pulse_seperation', 'Excluded spinEchoAmp vs. pulse_seperation', 'y = A*exp(t/t_2)', 'Location', 'NorthEast', 'Interpreter', 'none' );
% Label axes
xlabel('Pulse Seperation (ms)' );
ylabel('Spin Echo Amplitude');
title("Spin Echo Amplitude as a function of Pulse Seperation with exponential fit for " + sampleConcentration + " CuSO_4")
grid on
end
[fitresult, gof] = createFit(pulse_seperation, spinEchoAmp)
[fitresult, gof] = linearFit(pulse_seperation, logSpinamp)
end