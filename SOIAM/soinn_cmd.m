function predictCMD = soinn_cmd(soiam, soinn, inputData)
dsize=size(inputData,1);
if dsize > soiam.keyLength
   KeySignal=reshape(inputData((dsize-soiam.keyLength+2):dsize,:),1,[]);
   [value,minDist,winnerTime] = soiam_prediction(...
                                                 soinn,...
                                                 KeySignal,...
                                                 soiam.keyLength-1,...
                                                 0);
   predictCMD = value(1,soiam.predict1st:end);
else
    disp('data size is smaller than key-Value-Length');
end
%[EOP]
end