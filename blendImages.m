function blendImages(directory,N,resutDir)

cd(directory)
folderParts=regexp(directory,'\','split');
folderName = dir (['*' folderParts{end} '*']);
directory_A = [directory '\' folderName(1).name ];
directory_B = [directory '\' folderName(2).name ];

cd(directory_A)
fileList = dir('*.jpg');


cd(resutDir)
mkdir(folderName(1).name)
mkdir(folderName(2).name)

cd(directory)
temp = repmat(2.^[0:-1:-7],2,1);
temp = temp(:,1:end-1);
c = temp(:);
c = repmat(c,1,1024*512)';
c = reshape(c,512,1024,14);
parfor i=1:N
    sprintf(num2str(i))
    k=1;
    idx=randperm(length(fileList),1);
    [filepath,name,ext] = fileparts(fileList(idx).name);
    im_oct_1 = imread([folderName(1).name '\'  fileList(idx).name]);
    im_hist_1 = imread([folderName(2).name '\'  fileList(idx).name]);
    while k == 1
       idx_temp = randperm(length(fileList),1);
       [filepathTemp,nameTemp,extTemp] = fileparts(fileList(idx_temp).name);
       if strcmp(name(1:2),nameTemp(1:2))  
       else
          im_oct_2 = imread([folderName(1).name '\'  fileList(idx_temp).name]);
          im_hist_2 =imread([folderName(2).name '\'  fileList(idx_temp).name]);

          Oct_1 = steerablePyramidDecomposition(im_oct_1,'octave');
          Oct_2 = steerablePyramidDecomposition(im_oct_2,'octave');

          imHist1Nstc = rgb2ntsc(im_hist_1);
          imHist1DeformL = steerablePyramidDecomposition(squeeze(imHist1Nstc(:,:,1)),'octave');

          imHist2Nstc = rgb2ntsc(im_hist_2);
          imHist2DeformL = steerablePyramidDecomposition(squeeze(imHist2Nstc(:,:,2)),'octave');

          %hist_1_R = steerablePyramidDecomposition(squeeze(im_hist_1(:,:,1)),'octave');
          %hist_1_G = steerablePyramidDecomposition(squeeze(im_hist_1(:,:,2)),'octave');
          %hist_1_B = steerablePyramidDecomposition(squeeze(im_hist_1(:,:,3)),'octave');

          %hist_2_R = steerablePyramidDecomposition(squeeze(im_hist_2(:,:,1)),'octave');
          %hist_2_G = steerablePyramidDecomposition(squeeze(im_hist_2(:,:,2)),'octave');
          %hist_2_B = steerablePyramidDecomposition(squeeze(im_hist_2(:,:,3)),'octave');

          mask_oct = ~(im_oct_1==0).*~(im_oct_2==0);
          mask_hist = ~(im_hist_1==0).*~(im_hist_2==0);

          orientations = 4;
          levels = 7;
          ind = [];
          for j=1:levels
              ind_temp = datasample([2 + (j-1)*orientations:(j*orientations+1)],2,'Replace', false);
              ind = [ind ind_temp];
          end
          ind_diff = setdiff([1:size(Oct_1,3)],ind);

          %temp = repmat(2.^[0:-1:-7],2,1);
          %temp = temp(:,1:end-1);
          %c = temp(:);
          %c = repmat(c,1,1024*512)';
          %c = reshape(c,512,1024,14);

          rec_oct = sum(Oct_1(:,:,ind_diff),3) + sum(c.*Oct_2(:,:,ind),3) + sum((ones(512,1024,14)-c).*Oct_1(:,:,ind),3);
          rec_oct_real = real(rec_oct);

          rec_oct_unit8 = scale0To255(rec_oct_real);
          rec_oct_unit8 = rec_oct_unit8.*uint8(mask_oct);

          %rec_oct_real(mask_oct==0) = min(rec_oct_real,[],'all');
          %rec_oct_real = uint8(255 * mat2gray(rec_oct_real));

          rec_hist_L = real(sum(imHist1DeformL(:,:,ind_diff),3) + sum(c.*imHist2DeformL(:,:,ind),3) + sum((ones(512,1024,14)-c).*imHist1DeformL(:,:,ind),3));

          %rec_hist_R = real(sum(hist_1_R(:,:,ind_diff),3) + c*sum(hist_1_R(:,:,ind),3) + (1-c)*sum(hist_2_R(:,:,ind),3));
          %rec_hist_G = real(sum(hist_1_G(:,:,ind_diff),3) + c*sum(hist_1_G(:,:,ind),3) + (1-c)*sum(hist_2_G(:,:,ind),3));
          %rec_hist_B = real(sum(hist_1_B(:,:,ind_diff),3) + c*sum(hist_1_B(:,:,ind),3) + (1-c)*sum(hist_2_B(:,:,ind),3));

          rec_hist(:,:,1)  = rec_hist_L ;
          rec_hist(:,:,2)  = imHist1Nstc(:,:,2);
          rec_hist(:,:,3)  = imHist1Nstc(:,:,3);
          rec_hist = ntsc2rgb(rec_hist); 
          rec_hist_unit8 = scale0To255(rec_hist);
          rec_hist_unit8 =  rec_hist_unit8.*uint8(mask_oct);



          %rec_hist(:,:,1)  = rec_hist_R ;
          %rec_hist(:,:,2)  = rec_hist_G ;
          %rec_hist(:,:,3)  = rec_hist_B ;
          %rec_hist = uint8(255 * mat2gray(rec_hist,double([0,255])).*mask_oct);            

          imwrite(rec_oct_unit8,[resutDir '\' folderName(1).name '\blend_' num2str(i) '.jpeg'],'JPEG');
          imwrite(rec_hist_unit8,[resutDir '\' folderName(2).name '\blend_' num2str(i) '.jpeg'],'JPEG');


          k=0;
       end
    end

end