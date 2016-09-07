function drone_main()
% ********** Important Notice ************
% Start Sequence drone_main -> drone_video
% Close Sequence drone_video -> drone_main
% ****************************************
clc; clear all; close all;
addpath ./SOIAM;

disp('Control Mode (s/a):');
CK = input('Press Key ','s');
if CK == 's'
    disp('SOIAM mode');
    disp('Using existed SOIAM?');
    CS = input('(y/n) ','s');
    if CS == 'y'
        load('updatedsoiam.mat');
    else
        % Load Training data...
        trainD = soiam_access('rec.mat');
        % Train SOIAM...
        [soiam soinn] = soinn_train(trainD);
        disp('Finalizing SOIAM Training...'); disp(soinn);
        save('updatedsoiam');
    end
elseif CK == 'a'
    disp('Automate Mode');
else
    disp('Normal Mode')
end

% Instruction of Controlling ARDrone
% Manually control robot using W/S (forward/reverse), A/D
% (strafe left/right), I/K (vertical up/down), J/L (turn left/right)
% E (emergency stop), and Q (quit) keys

% Camera Check
% system('start ffplay -f h264 -i http://192.168.1.1:5555');
% delete('./rec/*.png'); % Clear Image Buffer
% initializing cmd
global drone_cmd;
drone_cmd = zeros(1,4);
iErrorx = 0; iErrory = 0;   % x- and y- Error estimator
px = 0; py = 0;

% Toggle Camera
%drone_toggleCAM(0);

% Open Camera Video
system('start Drone_Video_Yellow');
pause(5);

% Control of ARDrone
drone=drone_class;
drone.control;

% Command Callback
pause(1);
if CK=='s'
    t_soiam = timer(...
        'TimerFcn',@soiam_cmd,...
        'ExecutionMode','fixedRate',...
        'Period',.5);
    start(t_soiam);    
elseif CK=='a'
    t_pid = timer(...
        'TimerFcn',@pid_cmd,...
        'ExecutionMode','fixedRate',...
        'Period',.3);
    start(t_pid);
end

    function soiam_cmd(~,~)
        if ~isempty(findobj('type','figure','name','ARDrone Controller'))
            pos = drone_posi();
            if ~isempty(pos)
                tD = cpos_access(pos, drone_cmd);
                if size(tD,1) > 3
                    drone_cmd = soinn_cmd(soiam, soinn, tD);
                    drone.drive(drone_cmd);
                end
                disp(drone_cmd);
            end
        else
            stop(t_soiam); delete(t_soiam);
        end
    end
    function pid_cmd(~,~)
        if ~isempty( findobj('type','figure','name','ARDrone Controller'))
            pos = drone_posi();
            posX = pos(end,1);
            posY = pos(end,2);
            %disp([num2str(posX),' ',num2str(posY)]); % Pos Check-Point
            [evax iErrorx px] = pidc(posX, 1, iErrorx, px);
            [evay iErrory py] = pidc(posY, 1, iErrory, py);
            %[evaz iErrorz pz] = pidcz(drone.Z, 1, iErrorz, pz);
            if posX > 0 && posY > 0
                drone.drive([0 evax 0 0]);
                pause(.1);
                drone.drive([0 0 0 0]);
                pause(.1);
                drone.drive([0 0 evay 0]);
                disp([num2str(evax),' ',num2str(evay)]);
            elseif posX > 0 && posY < 0
                drone.drive([0 evax 0 0]);
                drone.drive([0 0 0 0]);
                drone.drive([0 0 evay 0]);
                disp([num2str(evax),' ',num2str(-evay)]);
            elseif posX < 0 && posY > 0
                drone.drive( [0 -evax 0 0]);
                drone.drive([0 0 0 0]);
                drone.drive( [0 0 evay 0]);
                disp([num2str(-evax),' ',num2str(evay)]);
            elseif posX < 0 && posY < 0
                drone.drive([0 -evax 0 0]);
                drone.drive([0 0 0 0]);
                drone.drive([0 0 evay 0]);
                disp([num2str(-evax),' ',num2str(-evay)]);
            elseif posY == 0
                if posX > 0
                    drone.drive([0 -evax 0 0]);
                    disp(['0',' ',num2str(evax)]);
                elseif posX < 0
                    drone.drive([0 evax 0 0]);
                    disp(['0',' ',num2str(-evax)]);
                end
            elseif posX == 0
                if posY > 0
                    drone.drive([0 evay 0 0]);
                    disp([num2str(evay),' ','0']);
                elseif posY < 0
                    drone.drive([0 -evay 0 0]);
                    disp([num2str(-evay),' ','0']);
                end
            else
                drone.drive([0 0 0 0]);
            end
            pause(.2);
            drone.drive([0 0 0 0]);
        else
            stop(t_pid); delete(t_pid);
        end    
    end
    function drone_toggleCAM(cam)
        instrreset
        % Creating ATCommand_PORT
        ARc = udp('192.168.1.1', 5556, 'LocalPort', 5556);
        % Opening UDP ports
        fopen(ARc);
        % Sending toggle Command
        if cam == 1
            AR_VDO_CONFIG = sprintf('AT*CONFIG=1,\"video:video_channel\",\"1\"\r');
            fprintf(ARc, AR_VDO_CONFIG);
        elseif cam == 0
            AR_VDO_CONFIG = sprintf('AT*CONFIG=1,\"video:video_channel\",\"0\"\r');
            fprintf(ARc, AR_VDO_CONFIG);
        else
            disp('Invalide Input Argument')
        end
        % Closing UDP ports
        fclose(ARc);
        % Wait for god sake
        pause(2);
    end
    function [preturn iError previous] = pidc(current, guard, iError, previous)
        % Scenario :
        % Error = target_pos-current_pos  //calculate error
        % P = Error * Kp                  //error times proportional constant gives P
        % I = I + Error                   //integral stores the accumulated error
        % I = I * Ki                      //calculates the integral value
        % D = Error-Previos_error         //stores change in error to derivate
        % Correction = P + I + D
        kp = 1;
        ki = 1;
        kd = 2;
        target = 0;
        % Instant error between target and current
        instant_error = target - current;
        pTerm = kp * instant_error;
        % Accumulated Error since PID creation
        iError = iError + instant_error;
        %
        if iError < - guard
            iError = -guard;
        elseif iError > guard
            iError = guard;
        end
        dTerm = kd * (current-previous);
        previous=current;
        preturn = pTerm + (ki * iError) - dTerm;
        preturn = abs(preturn/7);
    end
end