function posAng = cpos_access(pos, cmd)

% Converting XY coordination to angle
[posi_theta, posi_rho] = cart2pol(pos(:,1),pos(:,2));
soiam.maxRho = max(posi_rho);
posi_theta = posi_theta ./ pi;
posi_rho = posi_rho ./ soiam.maxRho;

% Mapping cmd to dataset
cmd = repmat(cmd,size(pos,1),1);

posAng = [posi_theta, posi_rho, cmd];
% inputD = inputD/norm(inputD); % Normalization

end
%[EOP]