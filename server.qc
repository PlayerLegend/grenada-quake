
//    world

void worldspawn()
{
    precache_model("progs/soldier.mdl");
    precache_model("progs/player.mdl");
}

void StartFrame()
{
    
}

//    client

void ClientConnect(optional float csqcactive)
{
    
}

void PutClientInServer()
{
    setup_player(self);
    place_here(find_player_spawn(self),self);
}

void PlayerPreThink()
{
    set_vector_space(self,self.v_angle);
    weapon_frame();
}

void PlayerPostThink()
{
    
}

void SV_RunClientCommand()
{
    player_physics(self,input_timelength);
}
