% Thanuja 20.07.2012
% Denoising EM image using K-SVD
% Using pre-trained dictionary for different sections

clear
%% Parameters
bb = 8; % block size
RR = 4; % redundancy factor
K = RR*bb^2; % number of atoms in the dictionary

sigma = 50; % expected noise level
pathForImages = '/home/thanuja/matlabprojects/data/mitoData/';
imageName = 'stem1.png';

%%
[IMin,pp]=imread(strcat([pathForImages,imageName]));
% fixing input image format
IMin=im2double(IMin);
if (length(size(IMin))>2)
    IMin = rgb2gray(IMin);
end
if (max(IMin(:))<2)
    IMin = IMin*255;
end
%% Denoising using K-SVD
% dictionary is trained on the noisy image
[IoutAdaptive,output] = denoiseImageKsvdReuseDict(IMin, sigma,K,bb);

%PSNROut = 20*log10(255/sqrt(mean((IoutAdaptive(:)-IMin0(:)).^2)));
figure();
imshow(IMin,[]); 
title('Noisy image');
figure();
imshow(IoutAdaptive,[]); 
title('Clean Image by Adaptive dictionary');
figure;
I = displayDictionaryElementsAsImage(output.D, floor(sqrt(K)), floor(size(output.D,2)/floor(sqrt(K))),bb,bb);
title('The dictionary trained on patches from the noisy image');