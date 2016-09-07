function posXY = drone_posi()

%rec_posi = load('example.txt');
% Assume Image with width : 638(640) / Height : 358(360)
Fid = fopen('rec_posi.txt');
if Fid > 0
    g = textscan(Fid,'%f64');
    m = cell2mat(g);
    rec_posi = (reshape(m',6,[]))';
    fclose('all');
    % Remaping to fit the data scale
    mposX = rangeMapper(rec_posi(:,5),0,640,-2, 2);
    mposY = rangeMapper(rec_posi(:,6),0,360,2, -2);
    posXY = [mposX mposY];
else
    disp('REC file not exist: wait for image to be taken');
    posXY = [0 0];
end

    function mvalue = rangeMapper (value, from_min, from_max, to_min, to_max)
        mvalue = (value - from_min) * (to_max - to_min) / (from_max - from_min) + to_min;
    end
end