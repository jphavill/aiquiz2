maxTrials = 100;
maxEpisodes = 500;
startY = 4;         % start state
startX = 1;

maxState = 4;       % compass directions as actions
UP = 1;
DOWN = 2;
RIGHT = 3;
LEFT = 4;

alpha = 0.5;        % parameterization
gamma = 1.0;
epsilon = 0.1;

maxVertical = 4;    % dimension of the cliff world
maxHorizontal = 12;

                    % initialization of the Q-value and epoch statistics
T_q = zeros(maxTrials,maxEpisodes);
bestQ = -100*ones(maxVertical,maxHorizontal,maxState);
bestTheta = 1000;

for (trial = 1:maxTrials)
    Q = zeros(maxVertical,maxHorizontal,maxState);
    
    for (epoch = 1:maxEpisodes)
		y = startY;
		x = startX;
		terminal = 0;

                    % choose an initial action
                    % epsilon-greedy policy for exploration--exploitation
		if rand(1) > epsilon
			[b, action] = max(Q(y,x,:));
		else
			action = randi(maxState);
		end

                    % repeat until terminal state encountered
		while (terminal ~= 1)
				r = -1;			            % default reward
				switch(action)
                    case UP                 % define next states
						next_y = y - 1;
						next_x = x;
						if (next_y < 1)		% attempted to 'exit' world
							next_y = y;
						end
					
					case DOWN
						next_y = y + 1;
						next_x = x;
						if (next_y > maxVertical)
							next_y = y;     % attempted to 'exit' world
						end

					case LEFT
						next_y = y;
						next_x = x - 1;
						if (next_x < 1)		% attempted to 'exit' world
							next_x = x;
						end
					case RIGHT
						next_y = y;
						next_x = x + 1;
						if (next_x > maxHorizontal)		% attempted to 'exit' world
							next_x = x;
						end
					otherwise
						error('Invalid action');
				end

			if rand(1) > epsilon            % epsilon-greedy exploration--exploitation
				[b, next_action] = max(Q(next_y,next_x,:));
			else
				next_action = randi(maxState);
			end

			if ((next_y == maxVertical) && (next_x == maxHorizontal))
				terminal = 1;               % terminal state
            elseif ((next_y == maxVertical) && (next_x ~= startX))
                r = -100;                   % cliff !!!
            end
                
                                            % Q-value update
            Q(y,x,action) = Q(y,x,action) + alpha * (r + gamma * Q(next_y,next_x,next_action) - Q(y,x,action));

            T_q(trial,epoch) = T_q(trial,epoch) + r;
            
            action = next_action;
            y = next_y;
            x = next_x;
            
            if (y == maxVertical)           % reset to start state if cliff...
                y = startY;
                x = startX;
            end
        end
    end
    
    theta = max(max(max(abs(bestQ - Q))));  % define theta change
    
    if (bestTheta > theta)                  % test for sufficiently small update
        bestTrial = trial;
        bestQ = Q;
        bestTheta = theta;
    end
end

bestQ
%plot(T_q(bestTrial,:))
ylim([-100 0])

TT = zeros(1,maxEpisodes);
for (epoch = 1:maxEpisodes)
    TT(epoch) = sum(T_q(:,epoch))/maxTrials;
end

hold on
plot(TT)

Policy = zeros(maxVertical,maxHorizontal);

for (y = 1:maxVertical)
	for (x = 1:maxHorizontal)
		[b, action] = max(bestQ(y,x,:));
		switch(action)
			case UP
			Policy(y,x) = UP;
			
			case DOWN
			Policy(y,x) = DOWN;
			
			case RIGHT
			Policy(y,x) = RIGHT;
						
			case LEFT
			Policy(y,x) = LEFT;
			
			otherwise
				error('Invalid action');
		end
	end
end
