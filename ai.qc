//    generic machine

float ai_frametime = 0.1;

struct ai_action {
    float(entity user) weigh;
    void(entity user) execute;
};

typedef struct ai_action ai_action;

struct ai_metadata{
    ai_action * action_list;
    ai_action * current_action;
    float next_choose;
    float bump_angle;
    float last_bump;
};

.ai_metadata * aimeta;

ai_action * ai_choose(entity user, ai_action * list)
{
    ai_action * use_action = list;
    float use_weight = 0;
    float weight;
    while(list->weigh != __NULL__)
    {
	weight = list->weigh(user);

	if( weight > use_weight )
	{
	    use_weight = weight;
	    use_action = list;
	}

	list++;
    }

    return use_action;
}

void ai_think()
{
    if( self.aimeta->next_choose <= time )
	self.aimeta->current_action = ai_choose(self,self.aimeta->action_list);
    
    ai_action * action = self.aimeta->current_action;

    if( action == __NULL__ )
    {
	error(strcat("Null ai_action in '",self.classname,"'\n"));
	return;
    }

    action->execute(self);

    self.nextthink = time + ai_frametime;
}

void ai_turntoangle(entity target, float wishangle, float anglespeed)
{
    float anglediff = balance_angle(wishangle - target.angles_y);
    
    if( anglediff > anglespeed )
	anglediff = anglespeed;
    else if( anglediff < -anglespeed )
	anglediff = -anglespeed;

    target.angles_y = balance_angle(target.angles_y + anglediff);
}

void ai_execute_bumpmove(entity target)
{
    float dist = target.maxspeed * ai_frametime;

    vector target_disp = target.goalentity.origin - target.origin;

    float target_angle = vectoangles(target.goalentity.origin - target.origin).y;

    float use_angle;
    float turnspeed;

    if(target.aimeta->last_bump < time - 2)
	
	use_angle = target_angle;
    else
	use_angle = target.aimeta->bump_angle;

    title_float("bump angle", self.aimeta->bump_angle);
    title_float("use angle", use_angle);
    
    if(target.aimeta->last_bump < time - 3)
	turnspeed = 90;
    else
	turnspeed = 360;

    ai_turntoangle(target,use_angle,turnspeed * ai_frametime);
    
    entity oldself = self;
    self = target;

    if(walkmove(self.angles_y,5) == 0 && (target.aimeta->last_bump < time - 0.7 || fabs(self.angles_y - self.aimeta->bump_angle) < 1))
    {
	set_vector_space(self,self.angles);
	tracebox(self.origin + '0 0 8',self.mins,self.maxs,self.origin + ' 0 0 8' + self.vspace.forward * 16,false,self);

	for(int i = 0; i < 10; i++)
	{
	    if(trace_plane_normal_x == 0 && trace_plane_normal_y == 0)
		self.aimeta->bump_angle = 30 * crandom2() + self.angles_y + 180;	    
	    else
		self.aimeta->bump_angle = vectoangles(trace_plane_normal + 0.5 * self.vspace.forward + 2 * random() * normalize(target_disp)).y + 45 * crandom2();

	    if( walkmove(self.aimeta->bump_angle,1) == 1 )
		break;
	}
	self.aimeta->last_bump = time + random();
    }

    self.aimeta->bump_angle = balance_angle(self.aimeta->bump_angle);
    
    self = oldself;
}

//    soldier

void soldier_execute_bumpmove(entity target)
{
    target.enemy = target.goalentity = find(world,classname,"player");
    ai_execute_bumpmove(target);
}

float soldier_weigh_bumpmove(entity target)
{
    return random();
}

ai_action soldier_action_list[2] =
{
    { soldier_weigh_bumpmove, soldier_execute_bumpmove }
};
