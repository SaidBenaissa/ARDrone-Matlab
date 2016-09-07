function [soiam soinn] = soinn_train(inputD)
%% SOIAM
soiam.keyLength = 3; % Runing data length
soiam.predict1st = 3; % The 1st output required to be predicted
soiam.DataDim = 6; % No. of dimension of input data

%% SOINN TRAIN
deleteNodePeriod = 4000;
maxEdgeAge = 750;
dataDimension = size(inputD, 2);
soinn = Soinn(deleteNodePeriod, maxEdgeAge, dataDimension);
disp(soiam);
disp('Training SOIAM...');
for i = 1:size(inputD,1)
    if(i > soiam.keyLength)
        signal=reshape(inputD(i-soiam.keyLength+1:i,:),1,[]);
        soinn.inputSignal(signal);
    end
end

end