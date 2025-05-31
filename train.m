% train_cnn.m
% Huấn luyện mạng CNN để hồi quy biên độ dao động Z từ ảnh vân thực tế

% TẢI NHÃN
load('labels.mat');                     % labels: [amplitude, frequency]
amplitudes = labels(:, 1);             % Chỉ dùng cột biên độ

fileList = dir(fullfile('dataset_with_freq', '*.tif'));
filePaths = fullfile({fileList.folder}, {fileList.name})';
numSamples = numel(filePaths);

% CHIA DỮ LIỆU TRAIN / VAL
rng(0);  % random cố định
idx = randperm(numSamples);
trainIdx = idx(1:round(0.8 * numSamples));
valIdx = idx(round(0.8 * numSamples) + 1:end);

% IMAGE DATASTORE VỚI ĐỌC & RESIZE
resizeSize = [128 128];
readAndResize = @(x) imresize(im2double(imread(x)), resizeSize);

trainImages = imageDatastore(filePaths(trainIdx), 'ReadFcn', readAndResize);
valImages   = imageDatastore(filePaths(valIdx),   'ReadFcn', readAndResize);

trainLabels = amplitudes(trainIdx);  % chỉ lấy biên độ
valLabels   = amplitudes(valIdx);

trainDS = combine(trainImages, arrayDatastore(trainLabels));
valDS   = combine(valImages, arrayDatastore(valLabels));

% CẤU TRÚC CNN HỒI QUY
layers = [
    imageInputLayer([128 128 1], 'Name', 'input')

    convolution2dLayer(3, 8, 'Padding', 'same')
    batchNormalizationLayer
    reluLayer
    maxPooling2dLayer(2, 'Stride', 2)

    convolution2dLayer(3, 16, 'Padding', 'same')
    batchNormalizationLayer
    reluLayer
    maxPooling2dLayer(2, 'Stride', 2)

    fullyConnectedLayer(64)
    reluLayer
    fullyConnectedLayer(1)
    regressionLayer
];

% HUẤN LUYỆN
options = trainingOptions('adam', ...
    'MaxEpochs', 800, ...
    'MiniBatchSize', 32, ...
    'InitialLearnRate', 1e-3, ...
    'ValidationData', valDS, ...
    'Plots', 'training-progress', ...
    'Verbose', false);

net = trainNetwork(trainDS, layers, options);
save('trainedAzNet1.mat', 'net');
disp('✅ Huấn luyện xong và đã lưu mạng CNN.');
