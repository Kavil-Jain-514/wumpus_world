% Define the predicates
:- dynamic
  	agent_position/2,
    wumpus_position/2,
    pit_position/2,
    gold_position/2,
    agent_health/1,
    agent_in_cave/1,
	my_map/1.

% ------- Start the Game ------

begin_game :-
    format('Welcome to Hunt the Wumpus~n'),
    create_matrix(4,4,M),
    replace_row_col(M,1,1,x,NewMatrix),
    assert(my_map(NewMatrix)),
    show_map(NewMatrix),
    initialize,
    game_loop.

% Display available actions to the user
user_menu :-
    format('Actions available to the user:
            1.Up ⇡
            2.Down ⇣ 
            3.Right ⇢
            4.Left ⇠\n'),
    write('Select an option\n'),
    read(UserOption),
    execute_user_action(UserOption).

% Initialize the game state
initialize :-
    initialize_agent,
    initialize_wumpus,
    initialize_sensors.

% Display initial sensors
initialize_sensors :-
    stench(Stench),
    breeze(Breeze),
    glitter(Glitter),
    format('Sensors: [Stench(~p),Breeze(~p),Glitter(~p)]\n', [Stench,Breeze,Glitter]).

% Initialize the positions of wumpus, pit, and gold
initialize_wumpus :-
    assert(wumpus_position(2,2)),
    assert(pit_position(3,3)),
    assert(gold_position(2,3)).

% Initialize the agent with its position, health, and in-cave status
initialize_agent :-
    assert(agent_position(1,1)),
    assert(agent_health(alive)),
    assert(agent_in_cave(yes)).

% Main game loop
game_loop :-
    can_execute_action(Result),
    Result == yes, !,
    user_menu.


% Execute the selected user action
execute_user_action(UserOption) :-
    UserOption == 1, move_up, game_loop;
    UserOption == 2, move_down, game_loop;
    UserOption == 3, move_right, game_loop;
    UserOption == 4, move_left, game_loop.

% Move the agent up
move_up :- 
    agent_position(X,Y),
    X1 is X - 1,
    my_map(M),
    replace_row_col(M,X,Y,+,M1),
    replace_row_col(M1,X1,Y,x,NewMatrix),
	show_map(NewMatrix),
    format('Agent Position: ~p\n',[agent_position(X1,Y)]),
    retractall(agent_position(_,_)),
	assert(agent_position(X1,Y)),
    retractall(my_map(_)),
    assert(my_map(NewMatrix)),
    update_agent_health,
	stench(Stench),
    breeze(Breeze),
    glitter(Glitter),
    format('Sensors: [Stench(~p),Breeze(~p),Glitter(~p)]\n', [Stench,Breeze,Glitter]).

% Move the agent down
move_down :- 
    agent_position(X,Y),
    X1 is X + 1,
    my_map(M),
    replace_row_col(M,X,Y,+,M1),
    replace_row_col(M1,X1,Y,x,NewMatrix),
	show_map(NewMatrix),
	format('Agent Action: ~p\n',[agent_position(X1,Y)]),
    % Update Position of Agent and Map
    retractall(agent_position(_,_)),
	assert(agent_position(X1,Y)),
    retractall(my_map(_)),
    assert(my_map(NewMatrix)),
    update_agent_health,
    stench(Stench),
    breeze(Breeze),
    glitter(Glitter),
    format('Sensors: [Stench(~p),Breeze(~p),Glitter(~p)]\n', [Stench,Breeze,Glitter]).

% Move the agent right
move_right :- 
    agent_position(X,Y),
    Y1 is Y + 1,
    my_map(M),
    replace_row_col(M,X,Y,+,M1),
    replace_row_col(M1,X,Y1,x,NewMatrix),
	show_map(NewMatrix),
	format('Agent Action: ~p\n',[agent_position(X,Y1)]),
    % Update Position of Agent and Map
    retractall(agent_position(_,_)),
	assert(agent_position(X,Y1)),
    retractall(my_map(_)),
    assert(my_map(NewMatrix)),
    update_agent_health,
    stench(Stench),
    breeze(Breeze),
    glitter(Glitter),
    format('Sensors: [Stench(~p),Breeze(~p),Glitter(~p)]\n', [Stench,Breeze,Glitter]).

% Move the agent left
move_left :- 
    agent_position(X,Y),
    Y1 is Y - 1,
    my_map(M),
    replace_row_col(M,X,Y,+,M1),
    replace_row_col(M1,X,Y1,x,NewMatrix),
	show_map(NewMatrix),
	format('Agent Action: ~p\n',[agent_position(X,Y1)]),
    % Update Position of Agent and Map
    retractall(agent_position(_,_)),
	assert(agent_position(X,Y1)),
    retractall(my_map(_)),
    assert(my_map(NewMatrix)),
    update_agent_health,
    stench(Stench),
    breeze(Breeze),
    glitter(Glitter),
    format('Sensors: [Stench(~p),Breeze(~p),Glitter(~p)]\n', [Stench,Breeze,Glitter]).

% Sensors of Agent
stench(yes) :-
    agent_position(X,Y),
    X1 is X + 1,
    X0 is X - 1,
    Y1 is Y + 1,
    Y0 is Y - 1,
  ( wumpus_position(X1,Y) ;
    wumpus_position(X0,Y) ;
    wumpus_position(X,Y1) ;
    wumpus_position(X,Y0) ;
    wumpus_position(X,Y) ),
  !.

stench(no).

breeze(yes) :-
  agent_position(X,Y),
  X1 is X + 1,
  X0 is X - 1,
  Y1 is Y + 1,
  Y0 is Y - 1,
  ( pit_position(X1,Y) ;
    pit_position(X0,Y) ;
    pit_position(X,Y1) ;
    pit_position(X,Y0) ;
    pit_position(X,Y)  ),
  !.

breeze(no).

glitter(yes) :-
  agent_position(X,Y),
  gold_position(X,Y),
  !,
  display_results.

glitter(no).

% Check Health of Agent
can_execute_action(no) :-
    agent_health(dead), !,
    write('You are dead!\n').

can_execute_action(no) :-
    agent_in_cave(no), !,
    write('Game Over!\n').

can_execute_action(yes).

% Update Agents health based on the environment
update_agent_health :-
  agent_health(alive),
  agent_position(X,Y),
  wumpus_position(X,Y),
  !,
  retract(agent_health(alive)),
  assert(agent_health(dead)),
  format("The Wumpus Killed you~n").

update_agent_health :-
  agent_health(alive),
  agent_position(X,Y),
  pit_position(X,Y),
  !,
  retract(agent_health(alive)),
  assert(agent_health(dead)),
  format("You're stuck in the pit~n").

update_agent_health.

% Display the final results when the gold is found
display_results :-
    agent_position(X, Y),
    gold_position(X, Y),
    format('Congratulations! You found the gold and won the game!~n'),
    retract(agent_in_cave(yes)),
    assert(agent_in_cave(no)).

% Display the map
show_map(Map) :- 
    display_matrix(Map).

% Methods complementary

% Generate a list of dots ('·') of length N
generate_dots_list(N,L) :- generate_dots_list1(N, [], L).
generate_dots_list1(0, L, L) :- !.
generate_dots_list1(N, R, L) :- 
    N > 0,
    N1 is N-1,
    generate_dots_list1(N1, [·|R], L).

% Create a matrix with the specified number of rows and columns
create_matrix(Rows,Cols,Matrix) :-
    generate_dots_list(Cols,List),
    create_matrix1(Rows,[],List,Matrix).

% Helper predicate for creating a matrix
create_matrix1(0,M,_,M).
create_matrix1(N,R,L,M) :-
    N > 0,
    N1 is N - 1,
    append(R,[L],L1),
    create_matrix1(N1, L1,L, M).

% Replace the Nth element of a list with a new value
replace_nth(Index,List,Value,NewList) :-
    nth1(Index,List,_,Transfer),
    nth1(Index,NewList,Value,Transfer).

% Replace the element at the specified row and column in the matrix
replace_row_col(M,Row,Col,Cell,N) :-
    nth1(Row,M,Old),
    replace_nth(Col,Old,Cell,Upd),
    replace_nth(Row,M,Upd,N).

% Display a matrix
display_matrix([]).
display_matrix([H|T]) :-
    display_row(H),
    display_matrix(T).

% Display a row of the matrix
display_row([]) :-
    format('|\n').
display_row([H|T]) :-
    format('| ~p ',H),
    display_row(T).
