#define false 0
#define true 1
typedef int bool;

struct minmax_box
{
    vector min,max;
};

typedef struct minmax_box minmax_box;

minmax_box hull_small = { '-16 -16 -24', '16 16 32' };
minmax_box hull_big = { '-32 -32 -24', '32 32 64' };

enum
  {
    FL_Null = 0,
    FL_1 = 1,
    FL_2 = 2,
    FL_3 = 4,
    FL_4 = 8,
    FL_5 = 16,
    FL_6 = 32,
    FL_7 = 64,
    FL_8 = 128,
  };

enum
  {
    BUTTONFL__ATTACK = FL_1,
    BUTTONFL__JUMP = FL_2,
  };

#define WEAPON_SLOT_COUNT 8

struct vector_space
{
    vector forward, right, up;
};

typedef struct vector_space vector_space;

.vector_space vspace;

void set_vector_space(entity tgt, vector angles)
{
    makevectors(angles);
    tgt.vspace.forward = v_forward;
    tgt.vspace.right = v_right;
    tgt.vspace.up = v_up;
}

void title_float(string title, float val)
{
    dprint(strcat(title," ",ftos(val),"\n"));
}

void title_vector(string title, vector val)
{
    dprint(strcat(title," ",vtos(val),"\n"));
}

void title_string(string title, string val)
{
    dprint(strcat(title," ",val,"\n"));
}

float balance_angle(float angle)
{
    angle = angle % 360;
    
    if( angle > 180 )
	angle -= 360;
    else if( angle < -180 )
	angle += 360;

    return angle;
}

float bound_abs(float val, float abs)
{
    if(val > abs)
	return abs;
    if(val < -abs)
	return -abs;
    return val;
}

float crandom2()
{
    return (random() - 0.5) * 2;
}
