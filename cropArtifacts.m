function [cropped] = cropArtifacts(vid_name, minRow, maxRow, minCol, maxCol)

    % reload video with artifacts, crop every frame and save it in the 
    % new video
    
    %fixedFrame = frame(downEdge:upEdge, leftEdge:rightEdge,:);
    name = vid_name(1:length(vid_name)-4);
    ext = vid_name(length(vid_name)-4:length(vid_name));
    video = VideoReader(vid_name);
    cropped = VideoWriter(strcat(name,'_CROP',ext));
    open(cropped);
  %  StabilizedVid = vision.VideoFileWriter('VID_20180709_215736006_OUT.avi'); %strcat(name,'_CROPPED',ext));
    while hasFrame(video)
        fotograma = readFrame(video);
        fotograma_cropped = fotograma(minRow:maxRow, minCol:maxCol,:);
        writeVideo(cropped, fotograma_cropped);
    end
close(cropped)
end