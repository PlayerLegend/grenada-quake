
struct vector_space
{
    vector forward, right, up;
};

typedef struct vector_space vector_space;

void set_vector_space(vector_space * vspace, vector angles)
{
    makevectors(angles);
    vspace->forward = v_forward;
    vspace->right = v_right;
    vspace->up = v_up;
}

vector_space view_vspace;
vector_space view_vspace_flat;

struct {
    entity player;
}
    model_ent;

void start_model_ent(entity * model_ent, string model)
{
    if(*model_ent != world)
	error(strcat("Model ent for ",model," exists when it shouldn't\n"));
	
    *model_ent = spawn();
    
    setmodel(*model_ent,model);

    (*model_ent).drawmask = MASK_ENGINE;
}

vector origin_frame_delta;

void set_origin_frame_delta()
{
    static vector old_origin;

    vector origin = getviewprop(VF_ORIGIN);

    origin_frame_delta = origin - old_origin;

    old_origin = origin;
}

#define square(thing) ((thing) * (thing))

void title_float(string title, float val)
{
    print(strcat(title," ",ftos(val),"\n"));
}

void title_vector(string title, vector val)
{
    print(strcat(title," ",vtos(val),"\n"));
}

void title_string(string title, string val)
{
    print(strcat(title," ",val,"\n"));
}
