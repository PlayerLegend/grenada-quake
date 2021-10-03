void CSQC_Init(float apilevel, string enginename, float engineversion)
{
    start_model_ent(&model_ent.player,"progs/player.mdl");
}

void do_render()
{
    float addentities_mask = MASK_ENGINE;

//    if( !intermission )
//	addentities_mask |= MASK_VIEWMODEL;
    
    addentities( addentities_mask );

    renderscene();
}

void set_playermodel_ent()
{
    vector origin = getviewprop(VF_ORIGIN);
    setorigin(model_ent.player,origin - '0 0 22');

    static vector slosh_delta;

    slosh_delta *= 0.95;
    slosh_delta += origin_frame_delta;

    slosh_delta_z = 0;

    title_float("slosh ",vlen(slosh_delta));

    if( vlen(slosh_delta) > 1 )
    {
	vector model_angles = vectoangles(slosh_delta);

	model_angles.x *= 0.333;
	
	model_ent.player.angles = model_angles;
    }
}

void set_view_origin()
{
    vector origin_start = getviewprop(VF_ORIGIN);

    vector const_offset = '0 0 128';

    vector look_offset = -32 * view_vspace_flat.forward;

    vector total_offset = const_offset + look_offset;

    setviewprop(VF_ORIGIN,origin_start + total_offset);
}

void set_view_preamble(float width, float height)
{
    clearscene();

    drawfill('0 0 0', [width, height, 0], '0.1 0.1 0.1', 1, 0);

    set_origin_frame_delta();
	
    vector angles = getviewprop(VF_ANGLES);
    
    set_vector_space(&view_vspace,angles);

    angles_z = 0;
    angles_x = 0;
    
    set_vector_space(&view_vspace_flat,angles);
}

void set_view_angles()
{
    vector angles = getviewprop(VF_ANGLES);

    angles_x = 60;
    angles_z = 0;
    
    setviewprop(VF_ANGLES,angles);
}

void set_view_details(float width, float height)
{
    setviewprop(VF_PERSPECTIVE,0);
    setviewprop(VF_FOV,[width,height]);
}

void CSQC_UpdateView(float width, float height, float menushown) 
{
    set_view_preamble(width,height);

    set_playermodel_ent();
    
    set_view_origin();

    set_view_angles();

    set_view_details(width,height);
    
    do_render();
}
