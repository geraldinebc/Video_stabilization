clear
%Se leen los datos del archivo de video
name = 'tierra3';
extension = '.avi';
vid_name = strcat(name,extension);
video = VideoReader(vid_name);

%Se determinan las dimensiones del video
vidWidth = video.Width;
vidHeight = video.Height;

%Se crea una estructura vacía para guardar los frames del video
vid = struct('vid_orig',zeros(vidHeight,vidWidth,3,'uint8'),'vid_new',zeros(vidHeight,vidWidth,3,'uint8'));

%Se guarda cada frame original en la estructura hasta el final del video
i = 1;
while hasFrame(video)
    vid(i).vid_orig = readFrame(video);
    i = i+1;
end

j = 1;
tsum = 1;                         %Transformación acumulada

% Se crea el video de salida
OUT = '_OUT';
vid_out = strcat(name,OUT,extension);
video_out = VideoWriter(vid_out);
open(video_out);
vid(1).vid_new = vid(1).vid_orig; %Primer frame del video de salida

%Se accede a cada frame para realizar el proceso de estabilizacion
while j < i-1
    imgA = vid(j).vid_orig;
    imgB = vid(j+1).vid_orig;
    img1 = rgb2gray(imgA);
    img2 = rgb2gray(imgB);

    %Detección de Features
    %Se detectan los features de las imagenes con el Metodo SURF
    points1 = detectSURFFeatures(img1);
    points2 = detectSURFFeatures(img2);

    %Extracción de Vectores de Features
    %Se extraen los descriptores de cada imagen
    [features1,points1] = extractFeatures(img1,points1);
    [features2,points2] = extractFeatures(img2,points2);

    %Matching de Features
    %Se extraen los indices de los features que probablemente correspondan entre las imagenes
    index_pairs = matchFeatures(features1,features2,'MaxRatio',0.3);

    %Se ordenan los puntos de los features que coinciden entre las imagenes
    matched_points1 = points1(index_pairs(:,1));
    matched_points2 = points2(index_pairs(:,2));

    %Se estima la transformación afin utilizando el algoritmo MSAC
    [tform,pointsBm,pointsAm] = estimateGeometricTransform(matched_points2,matched_points1,'affine');

    %Se realiza la suma acumulativa de las transformaciones
    tsum = tsum * tform.T;

    %Se aplica la transformación acumulada
    img_trans = imwarp(imgB,affine2d(tsum),'OutputView',imref2d(size(img2)));

    vid(j+1).vid_new = img_trans;
    
    %Se crea el nuevo video estabilizado
    writeVideo(video_out,vid(j+1).vid_new);
    
    j = j + 1;
end

close(video_out);

leftEdge = 0;
upEdge = 0;
rightEdge = vidWidth;
downEdge = vidHeight;

%Calculo de bordes que no tienen artefactos negros
for k = 1:j-1
    [up, down, left, right] = FindMaxArtifactPenetration(vid(k).vid_new);
    leftEdge = max(left,leftEdge);
    rightEdge = min(right,rightEdge);
    upEdge = max(up,upEdge);
    downEdge = min(down, downEdge); 
end


cropped = cropArtifacts(vid_out, upEdge, downEdge, leftEdge, rightEdge);