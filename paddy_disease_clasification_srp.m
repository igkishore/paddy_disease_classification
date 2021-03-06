close all;
clear all;
clc;
% -----------------------------------------------------------------------------------------------------------------------
imgFolder1 = fullfile('rice_leaf_diseases','Leaf smut');
imgset1 = imageSet(imgFolder1);
% -----------------------------------------------------------------------------------------------------------------------
imgFolder2 = fullfile('rice_leaf_diseases','Brown spot');
imgset2 = imageSet(imgFolder2);
% -----------------------------------------------------------------------------------------------------------------------
imgFolder3 = fullfile('rice_leaf_diseases','Bacterial leaf blight');
imgset3 = imageSet(imgFolder3);
% -----------------------------------------------------------------------------------------------------------------------
%  Aldready Pre- processid
% preprocess('Leaf smut',imgset1);
% preprocess('Brown spot',imgset2);
% preprocess('Bacterial leaf blight',imgset3);

digitDatasetPath = fullfile('training set');
imds = imageDatastore(digitDatasetPath, ...
    'IncludeSubfolders',true,'LabelSource','foldernames');

% To Vies The Files
% figure;
% perm = randperm(368,20);
% for i = 1:20
%     subplot(4,5,i);
%     imshow(imds.Files{perm(i)});
% end

% check the Labels
labelCount = countEachLabel(imds)



%  Test Img
img = readimage(imds,1);
size(img)

%  Classifing The dataset
numTrainFiles = 100;
[imdsTrain,imdsValidation] = splitEachLabel(imds,numTrainFiles,'randomize');

% Defining The Layers
layers = [
    imageInputLayer([64 220 3])
    
    convolution2dLayer(4,8,'Padding',[1 1])
    convolution2dLayer(4,8,'Padding',[1 1])
    convolution2dLayer(4,8,'Padding',[1 1])
    batchNormalizationLayer
    reluLayer
    
    convolution2dLayer(5,16,'Padding',[2 2])
    convolution2dLayer(5,16,'Padding',[2 2])
    convolution2dLayer(5,16,'Padding',[2 2])
    batchNormalizationLayer
    reluLayer
    
    convolution2dLayer(5,32,'Padding',[2 2])
    convolution2dLayer(5,32,'Padding',[1 1])
    convolution2dLayer(5,32,'Padding',[1 1])
    batchNormalizationLayer
    reluLayer
    
    maxPooling2dLayer(2,'Stride',2)
    
    convolution2dLayer(3,64,'Padding',[1 1])
    convolution2dLayer(3,64,'Padding',[1 1])
    batchNormalizationLayer
    reluLayer
    
    maxPooling2dLayer(2,'Stride',2)
    
    convolution2dLayer(2,128,'Padding',[1 1])
    convolution2dLayer(2,128,'Padding',[1 1])
    batchNormalizationLayer
    reluLayer
    crossChannelNormalizationLayer(3)
   
    dropoutLayer
    fullyConnectedLayer(3)
    softmaxLayer
    classificationLayer];

options = trainingOptions('adam', ...
    'LearnRateSchedule','piecewise', ...
    'LearnRateDropFactor',0.2, ...
    'LearnRateDropPeriod',5, ...
    'SquaredGradientDecayFactor',0.999, ...
    'L2Regularization' ,1.0000e-05,...
    'MaxEpochs',30, ...
    'MiniBatchSize',25, ...
    'Shuffle','every-epoch', ...
    'ValidationData',imdsValidation, ...
    'ValidationFrequency',5, ...
    'Verbose',false, ...
    'Plots','training-progress');

%  Training 
net = trainNetwork(imdsTrain,layers,options);

%  Predicting
YPred = classify(net,imdsValidation);
YValidation = imdsValidation.Labels;

accuracy = sum(YPred == YValidation)/numel(YValidation)