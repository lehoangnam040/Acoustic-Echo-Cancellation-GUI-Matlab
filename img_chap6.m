I = imread('tiger.jpg');
s = size(I);
m = s(1);
n = s(2);
p = s(3);

% r = zeros(m, n, p, 'uint8');
% g = zeros(m, n, p, 'uint8');
% b = zeros(m, n, p, 'uint8');
% r(:,:,1) = I(:,:,1);
% g(:,:,2) = I(:,:,2);
% b(:,:,3) = I(:,:,3);

% figure('Name', 'RGB');
% subplot(2, 2, 1);
% imshow(I);
% subplot(2, 2, 2);
% imshow(r);
% subplot(2, 2, 3);
% imshow(g);
% subplot(2, 2, 4);
% imshow(b);

gray_I = rgb2gray(I);
figure('Name', 'Gray image');
imshow(gray_I);

% noisy_I = uint8(double(I) + randn(size(I)) * 50);
% figure('Name', 'Noisy image');
% imshow(noisy_I);

% bw = roipoly(I);
% figure('Name', 'ROI');
% imshow(bw);
bw2 = im2uint8(bw);
tiger = bitand(I, im2uint8(bw)); %uint8(double(gray_I).*bw);
figure('Name', 'tiger');
imshow(tiger);

t = bitcmp(gray_I);
figure('Name', 't');
imshow(t);
