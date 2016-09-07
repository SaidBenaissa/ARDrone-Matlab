classdef Soinn<handle
    % Self-Organizing Incremental Neural Network
    
    properties
        % Signal's dimension.
        dimension;
        
        % A period for deleting nodes. The nodes that doesn't satisfy some
        % condition are deleted every this period.
        deleteNodePeriod;
        
        % The maximum of edges' ages. If an edge's age is more than this,
        % the edge is deleted.
        maxEdgeAge;
        
        % The minimum of number for neighbors.
        minNeighborNumber = 1;
        
        % a matrix whose rows correspoind with signals of nodes.
        nodes;

        % the matrix express which nodes are connected (neighbor-node) 
        % and each edge age.
        adjacencyMat;

        inputNum;
        winTimes;
    end
    
    methods
        function obj = Soinn(deleteNodePeriod, maxEdgeAge, dimension)
            % constractor
            % @param {int} deleteNodePeriod
            %       A period deleting nodes. The nodes that doesn't satisfy
            %       some condition are deleted every this period.
            % @param {int} maxEdgeAge
            %       The maximum of edges' ages. If an edge's age is more
            %       than this, the edge is deleted.
            % @param {int} dimension 
            %       Number of dimension for signal
            obj.deleteNodePeriod = deleteNodePeriod;
            obj.maxEdgeAge = maxEdgeAge;
            obj.dimension = dimension;
            obj.nodes = [];
            obj.winTimes = [];
            obj.adjacencyMat = sparse([]);
            obj.inputNum = 0;
        end
        
        function obj = inputSignal(obj, signal)
            % @param {row vector} signal - new input signal
            obj.checkSignal(signal);
            obj.inputNum = obj.inputNum + 1;
            
            if obj.inputNum < 3 || isempty(obj.nodes)
                obj.addNode(signal);
                return;
            end
            
            [winner, dists] = obj.findNearestNodes(2,signal);
			simThresholds = obj.calculateSimiralityThresholds(winner);
            if any(dists > simThresholds)
                obj.addNode(signal);
            else
                obj.addEdge(winner);
                obj.incrementEdgeAges(winner(1));
                obj.deleteOldEdges(winner(1));
                obj.incrementWinTimes(winner(1));
                obj.updateWinner(winner(1), signal);
                obj.updateAdjacentNodes(winner(1), signal);
            end
            
            if mod(obj.inputNum, obj.deleteNodePeriod) == 0
                obj.deleteNoiseNodes();
            end
        end
        
        function show(obj, data)
            % Display SOINN's network in 2D.
            % This function selects first and second dimensions.
            hold on;
            %show data
            if exist('data', 'var')
                plot(data(:,1), data(:,2), 'xr');
            end
            % show edges
            for j = 1:size(obj.adjacencyMat,2)
                for k = j:size(obj.adjacencyMat, 1)
                    if obj.adjacencyMat(k,j) > 0
                        nk = obj.nodes(k,:);
                        nj = obj.nodes(j,:);
                        plot([nk(1), nj(1)], [nk(2), nj(2)], 'k');
                    end
                end
            end
            % show nodes
            plot(obj.nodes(:,1), obj.nodes(:,2), '.','Markersize',20);
            title(strcat('nodes:', num2str(size(obj.nodes,1)), ' edges:', num2str(sum(sum((obj.adjacencyMat > 0)))), ' ΣWinTime:', num2str(sum(obj.winTimes))));
            set(gca,'XGrid','on','YGrid','on');
            hold off
        end
        
        function bool = checkSignal(obj, signal)
			s = size(signal);
            if s(1) == 1 && s(2) == obj.dimension
				bool = true;
            else
                bool = false;
            end
        end

        function addNode(obj, signal)
            num = size(obj.nodes, 1);
            obj.nodes(num+1,:) = signal;
            obj.winTimes(num+1) = 1;
            if num == 0
                obj.adjacencyMat(1,1) = 0;
            else
                obj.adjacencyMat(num+1,:) = zeros(1, num);
                obj.adjacencyMat(:,num+1) = zeros(num+1, 1);
            end
        end

        function [indexes, sqDists] = findNearestNodes(obj, num, signal)
            indexes = zeros(num, 1);
            sqDists = zeros(num, 1);
            D = sum(((obj.nodes - repmat(signal, size(obj.nodes, 1), 1)).^2), 2);
            for i = 1:num
                [sqDists(i), indexes(i)] = min(D);
                D(indexes(i)) = inf;
            end
        end
        
        function simThresholds = calculateSimiralityThresholds(obj, nodeIndexes)
            simThresholds = zeros(length(nodeIndexes), 1);
            for i = 1: length(nodeIndexes)
                simThresholds(i) = obj.calculateSimiralityThreshold(nodeIndexes(i));
            end
        end

        function threshold = calculateSimiralityThreshold(obj, nodeIndex)
            if any(obj.adjacencyMat(:,nodeIndex))
                pals = obj.nodes(obj.adjacencyMat(:,nodeIndex) > 0,:);
                D = sum(((pals - repmat(obj.nodes(nodeIndex,:), size(pals, 1), 1)).^2), 2);
                threshold = max(D);
            else
                [~, sqDists] = obj.findNearestNodes(2, obj.nodes(nodeIndex, :));
                threshold = sqDists(2);
            end
        end

        function addEdge(obj, nodeIndexes)
            n = size(obj.adjacencyMat,1);
            for i = 1:length(nodeIndexes)
                obj.checkRange(nodeIndexes(i), [0,n+1]);
            end
            obj.adjacencyMat(nodeIndexes(1), nodeIndexes(2)) = 1;
            obj.adjacencyMat(nodeIndexes(2), nodeIndexes(1)) = 1;
        end

        function bool = checkRange(~, value, range)
            % check the value is in the range
            if range(1) < value && value < range(2)
                bool = true;
            else
                e = MException('Value:OutOfBounds', 'the value is out of the range.');
                throw(e);
            end
        end

        function incrementWinTimes(obj, index)
            obj.checkRange(index, [0,size(obj.nodes,1)+1]);
            obj.winTimes(index) = obj.winTimes(index) + 1;
        end

        function updateWinner(obj, winnerIndex, signal)
            % @param {int} winnerIndex - hte index of winner
            % @param {row vector} signal - inputted new signal
            w = obj.nodes(winnerIndex,:);
            obj.nodes(winnerIndex, :) = w + (signal - w)./obj.winTimes(winnerIndex);
        end

        function updateAdjacentNodes(obj, winnerIndex, signal)
            pals = find(obj.adjacencyMat(:,winnerIndex) > 0);
            for i = 1:length(pals)
                w = obj.nodes(pals(i),:);
                obj.nodes(pals(i), :) = w + (signal - w)./(100 * obj.winTimes(pals(i)));
            end
        end

        function incrementEdgeAges(obj, winnerIndex)
            indexes = find(obj.adjacencyMat(:,winnerIndex) > 0);
            for i = 1: length(indexes)
                obj.incrementAdjacencyMatrix(winnerIndex, indexes(i));
                obj.incrementAdjacencyMatrix(indexes(i), winnerIndex);
            end
        end

        function incrementAdjacencyMatrix(obj, i, j)
            obj.adjacencyMat(i, j) = obj.adjacencyMat(i, j) + 1;
        end

        function setAdjacencyMatrix(obj, i, j, value)
            obj.adjacencyMat(i, j) = value;
        end

        function deleteOldEdges(obj, winnerIndex)
            indexes = find(obj.adjacencyMat(:,winnerIndex) > 0);
            for i = 1: length(indexes)
                if obj.adjacencyMat(indexes(i), winnerIndex) > obj.maxEdgeAge + 1
                    obj.setAdjacencyMatrix(indexes(i), winnerIndex, 0);
                    obj.setAdjacencyMatrix(winnerIndex, indexes(i), 0);
                end
            end
        end

        function deleteNoiseNodes(obj)
            noises = sum(obj.adjacencyMat > 0) < obj.minNeighborNumber;
            obj.nodes(noises,:) = [];
            obj.winTimes(noises) = [];
            obj.adjacencyMat(noises, :) = [];
            obj.adjacencyMat(:, noises) = [];
        end
    end
end

