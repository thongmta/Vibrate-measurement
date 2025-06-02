% predict_image_from_file.m
% Chọn ảnh vân giao thoa bất kỳ và dự đoán biên độ dao động Z bằng mô hình CNN

% TẢI MẠNG ĐÃ HUẤN LUYỆN
load('trainedAzNet1.mat');

% CHỌN ẢNH
[filename, pathname] = uigetfile({'*.tif;*.png;*.jpg', 'Image Files (*.tif, *.png, *.jpg)'}, ...
                                 'Chọn ảnh vân giao thoa cần dự đoán');
if isequal(filename, 0)
    disp('❌ Không có ảnh nào được chọn.');
    return;
end

imgPath = fullfile(pathname, filename);
img = imread(imgPath);

% XỬ LÝ ẢNH ĐẦU VÀO
if size(img, 3) > 1
    img = rgb2gray(img);  % chuyển sang ảnh mức xám nếu là ảnh màu
end

img = im2double(img);  % chuyển về định dạng double [0, 1]
imgResized = imresize(img, [128 128]);  % resize phù hợp đầu vào mạng
imgResized = reshape(imgResized, [128 128 1]);  % thêm chiều kênh

% DỰ ĐOÁN BIÊN ĐỘ
Az_pred = predict(net, imgResized);

% HIỂN THỊ KẾT QUẢ
% figure('Name', 'Prediction Result');
% imshow(img, []);
% title(sprintf('Predicted Vibration Amplitude: %.2f nm', Az_pred), 'FontWeight', 'bold', 'FontSize', 12);
fprintf('📂 Ảnh đã chọn: %s\n', filename);
fprintf('🤖 Biên độ dao động Z dự đoán: %.2f nm\n', Az_pred);
