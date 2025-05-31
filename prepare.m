% generate_dataset.m
% Sinh ảnh vân giao thoa với thông số thực tế + nhiễu và lưu nhãn

lambda = 550;           % bước sóng ánh sáng (nm)
I0 = 120;               % cường độ trung bình
imgSize = 1024;         % ảnh 1024x1024
T = 300;                % bước thời gian mô phỏng
noise_std = 5;          % độ lệch chuẩn của nhiễu Gaussian
output_folder = 'dataset_with_freq';

if ~exist(output_folder, 'dir')
    mkdir(output_folder);
end

% Cấu hình biên độ và tần số
amplitudes = linspace(1, 100, 100);              % 100 giá trị biên độ từ 1 đến 100 nm
frequencies = linspace(2, 10, 10);               % 10 giá trị tần số từ 2 đến 10 Hz

N = length(amplitudes) * length(frequencies);    % Tổng số ảnh = 100 x 10 = 1000
labels = zeros(N, 2);                            % Cột 1: Amplitude, Cột 2: Frequency

index = 1;

for a = 1:length(amplitudes)
    Az = amplitudes(a);

    for f = 1:length(frequencies)
        freq = frequencies(f);
        labels(index, :) = [Az, freq];

        x = linspace(0, 4*pi, imgSize);
        acc = zeros(imgSize, imgSize);

        for t = 1:T
            z_t = Az * sin(2*pi * freq * t / T);           % z(t) = A*sin(2πft/T)
            dphi = 4 * pi * z_t / lambda;
            fringe = I0 * (0.5 + 0.5 * cos(x + dphi));
            frame = repmat(fringe, imgSize, 1);
            acc = acc + frame;
        end

        img = acc / max(acc(:));  % chuẩn hóa về [0, 1]
        img = imnoise(img, 'gaussian', 0, (noise_std/255)^2);

        fname = sprintf('%s/img_%04d.tif', output_folder, index);
        imwrite(im2uint16(img), fname);
        index = index + 1;
    end
end

save('labels.mat', 'labels');  % lưu nhãn: cột 1 = amplitude, cột 2 = frequency
disp('✅ Tạo ảnh và lưu nhãn xong.');
