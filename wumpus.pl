init :-
    init_player,
    init_states_wumpus,
    init_sensors.

init_sensors :-
    stench(Stench),
    breeze(Breeze),
    glitter(Glitter),
    format('Sensors: [Stench(~p),Breeze(~p),Glitter(~p),Scream(no)]\n', [Stench,Breeze,Glitter]).

init_states_wumpus :-
    assert(wumpus_position(2,2)),
    assert(pit_position(3,3)),
    assert(gold_position(2,3)).

init_player :-
    assert(player_position(1,1)),
    assert(player_health(alive)),
    assert(player_in_cave(yes)),
    assert(player_arrows(1)),
    assert(score(0)),
	assert(gold(0)).

start :-
    format('Welcome to Wumpus World~n'),
    create_matrix(4,4,M),
    replace_row_col(M,1,1,x,NewMatrix),
    assert(map(NewMatrix)),
    display_map(NewMatrix),
    init,
    game.    