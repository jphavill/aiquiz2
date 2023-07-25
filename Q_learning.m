maxTrials = 100;
maxEpisodes = 500;
startY = 4;
startX = 1;

maxState = 4;
UP = 1;
DOWN = 2;
RIGHT = 3;
LEFT = 4;

alpha = 0.5;
gamma = 1.0;
epsilon = 0.1;

maxVertical = 4;
maxHorizontal = 12;

T_q = zeros(maxTrials,maxEpisodes);
bestQ = -100*ones(maxVertical,maxHorizontal,maxState);
bestTheta = 1000;

for (trial = 1:maxTrials)
	Q = zeros(maxVertical,maxHorizontal,maxState);

	for (epoch = 1:maxEpisodes)
		y = startY;		                    % Initialize agent to start state
		x = startX;
		terminal = 0;

		while (terminal ~= 1)               % test for not the terminal state
			if rand(1) > epsilon			% choose A from S using Q greedily
				[b, action] = max(Q(y,x,:));
			else
				action = randi(maxState);   % or explore...
			end

			r = -1;			% Take action A, observe R and S'
			switch(action)
				case UP
					next_y = y - 1;
					next_x = x;
					if (next_y < 1)		% attempted to 'exit' world
						next_y = y;
					end
					
				case DOWN
					next_y = y + 1;
					next_x = x;
					if (next_y > maxVertical)
						next_y = y;
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

			% detect exit (terminal) state or cliff .... anything else not important
			if ((next_y == maxVertical) && (next_x == maxHorizontal))
				terminal = 1;
			elseif ((next_y == maxVertical) && (next_x ~= startX)) % ~= means !=
					r = -100;
			end

			[b, next_action] = max(Q(next_y,next_x,:));	% max_a Q(S', a)

			Q(y,x,action) = Q(y,x,action) + alpha * (r + gamma * Q(next_y,next_x,next_action) - Q(y,x,action));

			T_q(trial,epoch) = T_q(trial,epoch) + r;
			
			action = next_action;		% S <- S'
			y = next_y;
			x = next_x;
			
			if (y == maxVertical)       % reinitialize agent to start if cliff encountered
					y = startY;
					x = startX;
			end
		end
	end

	theta = max(max(max(abs(bestQ - Q))));

	if (bestTheta > theta)
			bestTrial = trial;
			bestQ = Q;
			bestTheta = theta;
	end
end

bestQ
ylim([-100 0])
%plot(T_q(bestTrial,:))
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
