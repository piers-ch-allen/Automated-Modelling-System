%Viscoelastic Properties MATLAB File-Compression Cylinders
%If you use this code or a section of this code for your own
% research, please cite this thesis as the source of where you
% got the code – thank you.
%Authors: Mr. Bernard Michael Lawless, Dr. Spencer C.
% Barnes, Dr. David G. Eckold
%Description: This script calculates the viscoelastic
% properties of a viscoelastic material. This material must
%have been evaluated on a BOSE (TA Instruments) 3200 DMA
%machine
%%
clc;
clear all;

%% Please define the following parameters
% Definition of Cylindrical Parameters
dcyl = 8; % Please state the diameter of the cylinder (in mm)
hcyl = 1; % Please state the height of the cylinder (in mm)
Wordbook = 'RHH214Anterior_cartilageSub3.dat'; % state
% wordbook name and file eg.'Test1.xlsx'
% Please ensure that in the spreadsheet; Time is in Column
%1, Displacement is in Column 2 and Load in Column 3.

%% Importing of Excel File
T = xlsread(Wordbook); % Read Wordbook (Excel File)
Time = T(:,1); % Time Data in Column 1
DisplacementData = T(:,2); % Displacement Data in Column 2
LoadData = T(:,3); % Load Data in Column 3
NumberOfRows = length(DisplacementData); % Count number of rows
MeanDisplacement = mean(DisplacementData); % Calculate mean of displacement
MeanLoad = mean(LoadData);% Calculate mean of load
Blank =' ';
ResultsDivider = '--------------------------------------';

%% FFT of Data
% Creation of Fourier transforms of data
nfft = 2^nextpow2(length(LoadData)); % Setting Data to the next power of 2
dx = abs(Time(find(diff(Time),1)+1)-Time(1)); % Measuring the Time Step
Fs = 1/dx; % Sampling Frequency
f = Fs/2*linspace(0,1,nfft/2+1);
fftDisp = fft(DisplacementData); % FFT of Disp Data
fftLoad = fft(LoadData); % FFT of Load Data
subplot(1,2,1), plot(f(2:end),2*abs(fftDisp(2:nfft/2+1))),
ylabel('Amplitude'), xlabel('Freq'), title('Disp') % Plot of FFT Disp
subplot(1,2,2), plot(f(2:end),2*abs(fftLoad(2:nfft/2+1))),
ylabel('Amplitude'), xlabel('Freq'), title('Load') % Plot of FFT Load
[MaxLoad, idx1]=max(abs(fftLoad(2:end))); % Finding the position of the peak of the fft of load
[MaxDisp, idx2]=max(abs(fftDisp(2:end))); % Finding the position of the peak of the fft of disp
r = abs(angle(fftLoad(idx1+1))-angle(fftDisp(idx2+1))); %Measure of phase angle in radians
deg = r*180/pi; % Converting the phase angle to degrees
disp(ResultsDivider)
disp(Wordbook)
if deg > 90 % If the phase angle is greater that 90 degree
 disp(Blank)
 disp('WARNING: THE PHASE ANGLE IS GREATER THAT 90 DEGREES!')
 disp(Blank)
 disp('WARNING: THE DISPLACEMENT IS LEADING THE LOAD - CHECK THE NATURAL FREQUENCY OF THE MATERIAL')
 degr=180-deg;
else % if the phase angle is less than 90 degree
 disp(Blank)
 disp('THE LOAD IS LEADING THE DISPLACEMENT - NORMAL')
 degr= deg;
end
ActualFrequency = f(idx1+1); % Measure of actual frequency from FFT

phaseangle=(-0.0667*ActualFrequency)+degr; % Calculation
%of actual phase angle with correction factor (see BOSE
%manual pg.14-10 for more information about the correction factor)
phaseradians = (phaseangle*pi)/180; % Converting phase angle from deg to radians
LossFactor = tan(phaseradians); % Loss Factor Calculation
X1 = ['Actual Frequency (Hz): ', num2str(ActualFrequency)];
X2 = ['Phase Angle (deg): ', num2str(phaseangle)];
X3 = ['Loss Factor ', num2str(LossFactor)];
X4 = ['Time Step (s): ', num2str(dx)];
X5 = ['Max Load and Disp Index: ', num2str(idx1), ',' , num2str(idx2)];
disp(Blank)
disp(X1)
disp(Blank)
disp(X2)
disp(Blank)
disp(X3)
disp(Blank)
disp(X4)
disp(Blank)
disp(X5)
disp(Blank)
%% Calculation of Cylinder Cross Sectional Area (CSA) and
%Shape Factor
CylinderCSA = (pi*dcyl^2)/4; % Cylinder CSA
ShapeFactor = (pi/hcyl)*((dcyl/2)^2); % Cylinder Shape Factor
%% Calculation of angular velocity
omega = 2*pi*ActualFrequency; % Angular velocity calculation
Radian = omega*Time; % Radians (w*t)
RadianLength = length(Radian);
%% Calculation of X, F, Strain, Stress
X = DisplacementData-MeanDisplacement; % Displacement around zero
F = LoadData-MeanLoad; % Load around zero

Strain = X/hcyl; %Strain Calculation
StrainLength = length(Strain);
Stress = F/CylinderCSA; %Stress Calculation
StressLength = length(Stress);
XMax = max(X); % Maximum Displacement
FMax = max(F); % Maximum Load
StressMax = max(Stress); % Maximum Stress
StrainMax = max(Strain); % Maximum Strain
%% Graphs of Stress and Strain
% Plot of time (s) vs Load (N) and Disp (mm)
figure
plotyy(Time,LoadData,Time,DisplacementData);
xlabel('Time (s)');
ylabel('Load(N)');
title(Wordbook);
legend('Load','Disp');
% Plot of time (s) vs Stress (MPa) and Strain
figure
plotyy(Time,Stress,Time,Strain);
xlabel('Time (s)');
ylabel('Stress(MPa)');
title('Time (s) vs Stress/Strain');
legend('Stress','Strain');
% Plot of time (rads) vs Stress (MPa) and Strain
figure
plotyy(Radian,Stress,Radian,Strain);
xlabel('Radians');
ylabel('Stress(MPa)');
title('Radians vs Stress/Strain');
legend('Stress','Strain');
%% Complex Stiffness (K*), Storage Stiffness (K') and Loss Stiffness (K'')
ComplexStiffness = MaxLoad/MaxDisp; % Calculation of Complex Stiffness
StorageStiffness = ComplexStiffness*cos(phaseradians); 
%Calculation of Storage Stiffness
LossStiffness = ComplexStiffness*sin(phaseradians); 
%Calculation of Loss Stiffness
StiffnessResult1 = ['Complex Stiffness (N/mm): ', num2str(ComplexStiffness)];
StiffnessResult2 = ['Storage Stiffness (N/mm): ', num2str(StorageStiffness)];

StiffnessResult3 = ['Loss Stiffness (N/mm): ', num2str(LossStiffness)];
disp(StiffnessResult1)
disp(StiffnessResult2)
disp(StiffnessResult3)
disp(Blank)
%% Complex Modulus (E*), Storage Modulus (E') and Loss
Modulus (E'')
ComplexModulusMPa = ComplexStiffness/ShapeFactor;
%Calculation of Complex Modulus
StorageModulusMPa = StorageStiffness/ShapeFactor;
%Calculation of Storage Modulus
LossModulusMPa = LossStiffness/ShapeFactor; 
%Calculation of Loss Modulus
ModulusResult1 = ['Complex Modulus (MPa): ', num2str(ComplexModulusMPa)];
ModulusResult2 = ['Storage Modulus (MPa): ', num2str(StorageModulusMPa)];
ModulusResult3 = ['Loss Modulus (MPa): ', num2str(LossModulusMPa)];
disp(ModulusResult1)
disp(ModulusResult2)
disp(ModulusResult3)
disp(Blank)
disp(Blank)
disp('END OF RESULTS')
disp(Blank)
disp(ResultsDivider)
%END