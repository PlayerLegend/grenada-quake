struct weapon_metadata {
    void(entity target) selector[WEAPON_SLOT_COUNT];
    void(entity target) frame;
    void(entity target) attack;
    bool(entity target) busy;
    float last_attack;
};

typedef struct weapon_metadata weapon_metadata;

.weapon_metadata * weapon_metadata;

void reset_weapon_state(entity target)
{
    target.weapon_metadata->frame = __NULL__;
    target.weapon_metadata->attack = __NULL__;
    target.weapon_metadata->busy = __NULL__;
    target.weaponmodel = "";
    target.currentammo = 0;
}

void weapon_setup_basic(entity target, string set_model, float set_ammo)
{
    target.weaponmodel = set_model;
    target.currentammo = set_ammo;
}

bool is_weapon_busy(entity target)
{
    if( !target.weapon_metadata->busy )
	return false;

    return target.weapon_metadata->busy(target);
}

void select_weapon()
{
    if( self.impulse < 1 || self.impulse >= WEAPON_SLOT_COUNT )
	return;

    if( is_weapon_busy(self) )
	return;

    void(entity target) selector = self.weapon_metadata->selector[self.impulse - 1];

    if( selector != __NULL__ )
    {
	reset_weapon_state(self);
	selector(self);
    }
    else
    {
	centerprint(self,strcat("Empty slot ",ftos(self.impulse)));
    }

    self.impulse = 0;
}

void weapon_frame()
{
    if( !self.weapon_metadata )
	return;
    
    select_weapon();

    if(self.weapon_metadata->frame)
	self.weapon_metadata->frame(self);
    
    if( self.button0 && self.weapon_metadata->attack && !is_weapon_busy(self) )
    {
	self.weapon_metadata->attack(self);
	self.weapon_metadata->last_attack = time;
    }
}

// axe

void axe_attack(entity target)
{
    title_float("attack",time);

    vector look = target.vspace.forward * 64;
    if( look_z < 0 )
	look_z = 0;
    
    tracebox(target.origin,target.mins,target.maxs,target.origin + look,false,target);

    if(trace_ent != world)
    {
	vector push = target.vspace.forward * 600;
	if( push_z < 127 )
	    push_z = 127;
	title_vector("push",push);
	trace_ent.velocity += push;
    }
}

bool axe_busy(entity target)
{
    return target.weapon_metadata->last_attack > time - 0.2;
}

void axe_selector(entity target)
{
    weapon_setup_basic(target,"progs/v_axe.mdl",1337);
    target.weapon_metadata->attack = axe_attack;
    target.weapon_metadata->busy = axe_busy;
}

// shotgun

void shotgun_selector(entity target)
{
    weapon_setup_basic(target,"progs/v_shot.mdl",1337);
}

// spawner

void setup_soldier(entity soldier);
void spawner_selector(entity target)
{
    void(entity target) setup = setup_soldier;

    entity new = spawn();
    setup(new);
    tracebox(target.origin + '0 0 16',target.mins,target.maxs,target.origin + target.vspace.forward * 1000,false,target);
    setorigin(new,trace_endpos);
}
