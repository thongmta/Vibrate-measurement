% predict_test.m
% Tạo ảnh vân giao thoa thực tế với biên độ Z biết trước và dự đoán bằng mô hình CNN

% TẢI MẠNG
load('trainedAzNet1.mat');

% THÔNG SỐ THỰC TẾ
lambda = 550;         % bước sóng ánh sáng (nm)
Az_true = 14.0;       % biên độ dao động trục Z thật (nm)
imgSize = 1024;       % ảnh vuông 1024x1024
I0 = 120;             % cường độ nền
pixel_size = 3.45;    % micron/pixel (không cần thiết cho CNN nhưng giữ lại)

T = 300;              % số bước thời gian mô phỏng
noise_std = 5;        % độ lệch chuẩn nhiễu Gaussian (tùy chỉnh được)

% TẠO ẢNH VÂN GIAO THOA
x = linspace(0, 4*pi, imgSize);
acc = zeros(imgSize, imgSize);

for t = 1:T
    z_t = Az_true * sin(2*pi * t / T);
    dphi = 4 * pi * z_t / lambda;  % lệch pha Michelson
    fringe = I0 * (0.5 + 0.5 * cos(x + dphi));
    frame = repmat(fringe, imgSize, 1);
    acc = acc + frame;
end

img = acc / max(acc(:));              % chuẩn hóa [0, 1]
img = imnoise(img, 'gaussian', 0, (noise_std/255)^2);  % thêm nhiễu Gaussian
imgResized = imresize(img, [128 128]); % resize theo mạng

% DỰ ĐOÁN
Az_pred = predict(net, imgResized);

% HIỂN THỊ
fprintf('🔬 Biên độ Z thực tế     : %.2f nm\n', Az_true);
fprintf('🤖 Biên độ Z dự đoán CNN : %.2f nm\n', Az_pred);

% HIỂN THỊ ẢNH VÂN
figure;
imshow(img, []);
title(sprintf('Ảnh vân thực tế (Az = %.2f nm, Dự đoán = %.2f nm)', Az_true, Az_pred));
