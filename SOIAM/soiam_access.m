function inputD = soiam_access(rec_f)

ardrone = load(rec_f);
% Accessing raw data from recording
rawD = ardrone.rec(:,2:end);

% Converting XY coordination to angle
[posi_theta, posi_rho] = cart2pol(rawD(:,1),rawD(:,2));
soiam.maxRho = max(posi_rho);
posi_theta = posi_theta ./ pi;
posi_rho = posi_rho ./ soiam.maxRho;

% Normalizing angular data
inputD = [posi_theta, posi_rho];
% inputD = inputD/norm(inputD);
inputD = [inputD rawD(:,3:end)];
end
%[EOP]