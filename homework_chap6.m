I = imread('tiger.jpg');
Y = zeros(size(I), 'like', I);

I(1:border,:,:) = 0;
I(end-border:end,:,:) = 0;
I(:,1:border,:) = 0;
I(:,end-border:end,:) = 0;

border = 50;
color = [255 255 255];

for i = 1:3
    Y(1:border,:,i) = color(i);
    Y(end-border:end,:,i) = color(i);
    Y(:,1:border,i) = color(i);
    Y(:,end-border:end,i) = color(i);
end

frame = imadd(I, Y);
% subplot(1, 2, 1);
% imshow(Y);
% subplot(1, 2, 2);
imshow(frame);