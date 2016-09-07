classdef drone_class < handle
    % ARDrone Class
    % Controls AR Parrot Drone
    properties
        seq = 3;
        ARc;
        ARn;
        % NavData Properties
        Control_State = [];
        Battery_Voltage = 0;
        Pitch = 0;
        Roll = 0;
        Yaw = 0;
        Altitude = 0;
        X_Velocity = 0;
        Y_Velocity = 0;
        Z_Velocity = 0;
        NavData = 0;
    end   
    methods      
        function [obj] = drone_class()
            instrreset           
            %Create Control connection
            obj.ARc = udp('192.168.1.1', 5556, 'LocalPort', 5556);
            fopen(obj.ARc);             
            %Create NavData connection
            obj.ARn = udp('192.168.1.1', 5554, 'LocalPort', 5554, ...
                'ByteOrder', 'littleEndian', ...
                'InputBufferSize', 500, ...
                'BytesAvailableFcn', {@navPacketRxCallback,obj}, ...
                'DatagramTerminateMode', 'off', ...
                'BytesAvailableFcnMode', 'byte', ...
                'BytesAvailableFcnCount', 30);
            fopen(obj.ARn);            
            % Byte to NavData port for initialization
            fwrite(obj.ARn, 1);
            % NavData command to command port
            AR_NAV_CONFIG = sprintf('AT*CONFIG=2,\"general:navdata_demo\",\"TRUE\"\r');
            fprintf(obj.ARc, AR_NAV_CONFIG);
            % Flicker LEDs
            % obj.command('LED', '1,5,5,5,5');
            function navPacketRxCallback(obj,~,drone)
                % Define Current time
                recdate = date;
                rectime = clock;
                % Define new data structure
                if exist(['DroneData_',recdate,'.mat'],'file') ~= 2
                    rec = zeros(1,11);
                    save(['DroneData_',recdate,'.mat'],'rec')
                end
                load(['DroneData_',recdate,'.mat']);
                
                if (get(obj, 'BytesAvailable') ~= 0)
                    data = fread(obj);
                    data = uint8(data);
                    if ~isempty(data);                       
                        % Drone Control State Information
                        drone_state = [data(5) data(6) data(7) data(8)];
                        drone_state = typecast(drone_state, 'uint32');
                        for i = 1:32
                            drone.Control_State(i) = bitget(drone_state, i);
                        end
                        
                        % Battery Voltage Percentage
                        vBattery = [data(25) data(26) data(27) data(28)];
                        drone.Battery_Voltage = typecast(vBattery, 'uint32');
                        
                        % Theta (Pitch) Values
                        tPitch = [data(29) data(30) data(31) data(32)];
                        drone.Pitch = typecast(tPitch, 'single') / 1000;
                        
                        % Phi (Roll) Values
                        tRoll = [data(33) data(34) data(35) data(36)];
                        drone.Roll = typecast(tRoll, 'single') / 1000;
                        
                        % Psi (Yaw) Values
                        tYaw = [data(37) data(38) data(39) data(40)];
                        drone.Yaw = typecast(tYaw, 'single') / 1000;
                        
                        % Altitude
                        tAltitude = [data(41) data(42) data(43) data(44)];
                        drone.Altitude = single(typecast(tAltitude, 'int32'))/ 1000;
                        
                        % X Velocity
                        Vx = [data(45) data(46) data(47) data(48)];
                        drone.X_Velocity = typecast(Vx, 'single') / 1000;
                        
                        % Y Velocity
                        Vy = [data(49) data(50) data(51) data(52)];
                        drone.Y_Velocity = typecast(Vy, 'single') / 1000;
                        
                        % Z Velocity
                        Vz = [data(53) data(54) data(55) data(56)];
                        drone.Z_Velocity = typecast(Vz, 'single') / 1000;                       
                        % Record Navigation Data
                        cstate = [...
                            single(rectime(4)),...
                            single(rectime(5)),...
                            single(rectime(6)),...
                            single(drone.Battery_Voltage),...
                            drone.Pitch,...
                            drone.Yaw,...
                            drone.Roll,...
                            drone.Altitude,...
                            drone.X_Velocity,...
                            drone.Y_Velocity,...
                            drone.Z_Velocity];
                        rec = [rec ; cstate];
                        save(['DroneData_',recdate,'.mat'],'rec');
                        % Entire NavData Packet
                        drone.NavData = data;
                    end                    
                    % Reset Drone Watchdog Bit
                    AR_WDG = strcat('AT*COMWDG=',num2str(drone.seq),',');
                    fprintf(drone.ARc, AR_WDG);
                    drone.seq = drone.seq + 1;              
                end
            end
        end  
        function command(obj, command_type, code)
            AR_CMD = sprintf('AT*%s=%i,%s\r', command_type, obj.seq, code);
            fprintf(obj.ARc, AR_CMD);
            obj.seq = obj.seq + 1;
        end
        function takeoff(obj)
            obj.command('FTRIM','')
            obj.command('CONFIG','\"control:altitude_max\", \"20000\"')
            obj.command('REF','290718208')
        end        
        function hover(obj)
            obj.drive([0,0,0,0])
        end       
        function land(obj)
            obj.command('REF','290717696')
        end       
        function emergency(obj)
            obj.command('REF','290717952')
            obj.command('REF','290717696')
        end       
        function drive(obj, speed)
            % Controls the robot movement directly using motor speeds
            fvel = typecast(single(speed(1)/2), 'int32');
            lvel = typecast(single(speed(2)/2), 'int32');
            uvel = typecast(single(speed(3)/2), 'int32');
            rvel = typecast(single(speed(4)/2), 'int32');
            fvel_str = strcat(num2str(fvel),',');
            lvel_str = strcat(num2str(lvel),',');
            uvel_str = strcat(num2str(uvel),',');
            rvel_str = num2str(rvel);
            obj.command('PCMD',strcat('1,',lvel_str,fvel_str,uvel_str,rvel_str))
        end       
        function moveUp(obj, speed)
            obj.drive([0,0,speed,0])
        end       
        function moveDown(obj, speed)
            obj.drive([0,0,-speed,0])
        end       
        function moveLeft(obj, speed)
            % Moves the robot left at a specific speed
            obj.drive([0,-speed,0,0])
        end      
        function moveRight(obj, speed)
            % Moves the robot right at a specific speed
            obj.drive([0,speed,0,0])
        end      
        function moveForward(obj, speed)
            % Moves the robot forward at a specific speed
            obj.drive([-speed,0,0,0])
        end      
        function moveReverse(obj, speed)
            % Moves the robot forward at a specific speed
            obj.drive([speed,0,0,0])
        end        
        function rotateLeft(obj, omega)
            % Rotates robot left
            obj.drive([0,0,0, -omega])
        end        
        function rotateRight(obj, omega)
            obj.drive([0,0,0, omega])
        end        
        function stop(obj)
            % Stop all Robot motion and close communications.
            obj.land
            fclose(obj.ARn);
            fclose(obj.ARc);
        end   
        function control(obj, varargin)
            clc;
            disp('Controls');
            disp('arrow keys = up,down,rotate_left,rotate_right');
            disp( 'w,a,s,d = move:forward,backward,left,right');
            disp('enter,spacebar,shift = takeoff,land,hover');
            disp('q = quit program');           
            % Manually control robot using W/S (forward/reverse), A/D
            % (strafe left/right), I/K (vertical up/down), J/L (turn left/right)
            % E (emergency stop), and Q (quit) keys.
            global fh;
            if nargin == 2
                vel = varargin{1};
            else
                vel = .23;
            end
            % Control Pannel Window
            left = 100; bottom = 100; width = 250; height = 120;
            fh = figure(...
                'name','ARDrone Controller', ...
                'keypressfcn',@keyPress, ...
                'windowstyle','modal',...
                'numbertitle','off', ...
                'Position',[left bottom width height],...
                'userdata','timeout',...
                'Color','white') ; 
            function keyPress(~,event)
                cmd = event.Key;                
                switch (cmd)                    
                    case 'return' % Take off
                        obj.takeoff()
                    case 'space' % Land
                        obj.land()
                    case 'e' % Emergency
                        obj.emergency()
                    case 'leftarrow' % Rotate Left
                        obj.rotateLeft(vel)
                    case 'rightarrow' % Rotate Right
                        obj.rotateRight(vel)
                    case 'uparrow' % Up
                        obj.moveUp(vel)
                    case 'downarrow' % Down
                        obj.moveDown(vel)
                    case 'shift' % Hover
                        obj.hover()
                    case 'a' % Left
                        obj.moveLeft(vel)
                    case 'd' % Right
                        obj.moveRight(vel)
                    case 'w' % Forward
                        obj.moveForward(vel)
                    case 's' % Backward
                        obj.moveReverse(vel)
                    case 'q'
                        disp('Quitting...');
                        obj.command('REF','290717952');
                        close all; clear all;
                        instrreset;
                    otherwise
                        disp('Unknown Command')
                end
            end

        end
    end
end
