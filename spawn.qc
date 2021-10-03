entity find_spawn(string name)
{
    int count = 0;

    entity e;

    e = world;
    while( (e = find(e,classname,name)) )
	count++;

    int rand = (count + 1) * 0.99 * random();

    e = world;
    while( rand > 0 || e == world )
    {
	e = find(e,classname,name);
	rand--;

	if( rand < -5 )
	{
	    error(strcat("Could not find a spawner called '",name,"', there are ",ftos(count)," such spawners\n"));
	    return world;
	}
    }

    return e;
}

void place_here(entity spawner, entity target)
{
    setorigin(target,spawner.origin);
    target.angles = spawner.angles;
    target.fixangle = true;
}

//    player

entity find_player_spawn(entity player)
{
    return find_spawn("player_spawn");    
}

void setup_player(entity player)
{
    player.classname = "player";
    player.movetype = MOVETYPE_WALK;
    player.solid = SOLID_SLIDEBOX;
    setmodel(player,"progs/player.mdl");
    setsize(player,hull_small.min,hull_small.max);
    player.view_ofs = '0 0 22';
    player.phys_vars = &default_phys_vars;
    if(player.weapon_metadata == __NULL__)
	player.weapon_metadata = memalloc(sizeof(*player.weapon_metadata));
    memfill8(player.weapon_metadata,0,sizeof(*player.weapon_metadata));
    
    player.weapon_metadata->selector[0] = axe_selector;
    player.weapon_metadata->selector[1] = shotgun_selector;
    player.weapon_metadata->selector[2] = spawner_selector;

    axe_selector(player);
    player.health = 100;
    player.deadflag = 2;
}

void start_player_spawner()
{
    self.classname = "player_spawn";
}

void info_player_start()
{
    start_player_spawner();
}

void info_player_deathmatch()
{
    start_player_spawner();
}

void info_player_coop()
{
    start_player_spawner();
}

//    soldier

void setup_soldier(entity soldier)
{
    soldier.classname = "soldier";
    soldier.movetype = MOVETYPE_STEP;
    soldier.solid = SOLID_SLIDEBOX;
    setmodel(soldier,"progs/soldier.mdl");
    setsize(soldier,hull_small.min,hull_small.max);
    soldier.health = 50;

    if( ! soldier.aimeta )
	soldier.aimeta = memalloc(sizeof(*soldier.aimeta));

    memfill8(soldier.aimeta,0,sizeof(*soldier.aimeta));

    soldier.aimeta.action_list = soldier_action_list;

    soldier.think = ai_think;
    soldier.nextthink = time + random();
    soldier.maxspeed = 100;
}

