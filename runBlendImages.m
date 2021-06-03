clear; clc; close all;
N = 10000; % Number of images to blend
train = 'F:\Users\Itamar\OCT\steerable_pyramid_pre_process\data\data for blending\train'; % train folder should contain train_A (OCT) and train_B (histology)   
resutDir = 'F:\Users\Itamar\OCT\steerable_pyramid_pre_process\data\blend_6\';
blendImages(train,N,resutDir)