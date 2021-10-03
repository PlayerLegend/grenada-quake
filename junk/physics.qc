struct {
    float maxspeed, friction, stopspeed, gravity;
} player_phys_var;

void update_player_phys_var()
{
    player_phys_var.maxspeed = cvar("sv_maxspeed");
    player_phys_var.friction = cvar("sv_friction");
    player_phys_var.stopspeed = cvar("sv_stopspeed");
    player_phys_var.gravity = cvar("sv_gravity");
}

float player_phys_slide(float ptime)
{
  float speed = vlen(self.velocity);

  if(speed == 0)
    return 0;
  
  vector displace = self.velocity * ptime;

  tracebox(self.origin, self.mins, self.maxs, self.origin + displace,false,self);
  self.velocity -= trace_plane_normal * (trace_plane_normal * self.velocity);

  float dist = vlen(trace_endpos - self.origin);

  self.origin = trace_endpos;

  return ptime - (dist / speed);
}

vector player_phys_wishvel_ground()
{
  vector ret =
    (
     v_forward * input_movevalues_x +
     v_right * input_movevalues_y
     );

  ret_z = 0;

  float max_speed = player_phys_var.maxspeed;
  
  if(ret*ret > max_speed*max_speed)
    ret = max_speed * normalize(ret);
  
  return ret;
}

void player_phys_groundfriction()
{
  vector delta = player_phys_wishvel_ground() - self.velocity;

  delta_z = 0;

  float dlen = vlen(delta);
  
  float stopscale = input_timelength * player_phys_var.friction;
  
  delta *= stopscale;

  if(vlen(self.velocity) < player_phys_var.stopspeed)
    delta *= 2;

  //print_float("dlen",dlen);

  //if(dlen < 100)
  //delta /= dlen / 100;

  self.velocity += delta;
}

void player_phys_airfriction()
{
  vector wishvel = player_phys_wishvel_ground();
  vector wishdir = normalize(wishvel);
  vector delta = wishvel - wishdir*(wishdir*self.velocity);

  delta_z = 0;

  delta *= input_timelength;

  self.velocity += delta;
}
void player_phys_frame()
{
  vector origin_start = self.origin;
  
  makevectors([0,input_angles_y,0]);
  float slide_time = input_timelength;
  int count = 10;
  float t_epsilon = slide_time / 20;
  self.velocity -= input_timelength * '0 0 1' * player_phys_var.gravity;

  
  while(1)
    {
      slide_time = player_phys_slide(slide_time);
      if(count-- < 0 || slide_time < t_epsilon)
	break;
    }

  tracebox(self.origin,self.mins,self.maxs,self.origin - '0 0 1',false,self);

  if(trace_fraction < 1.0)
    self.flags |= FL_ONGROUND;
  else
    self.flags &= ~FL_ONGROUND;

  
  if(self.flags & FL_ONGROUND && self.button2)
    {
      self.velocity += '0 0 270';
      self.flags &= ~FL_ONGROUND;
    }
  else if(self.flags & FL_ONGROUND)
    {
      player_phys_groundfriction();
    }
  else
    player_phys_airfriction();
  
  setorigin(self,self.origin);
}
