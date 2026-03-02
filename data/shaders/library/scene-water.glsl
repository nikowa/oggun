

// csd_t csdf_surf(vec3 c) {
// 	csd_t surf=csdf_sphere(c-vec3(0,0,8-0.1),8,SURF);
// 	surf=csdf_diff(surf,csdf_plane(c-vec3(0,0,-7.9+8-0.1),vec3(0,0,-1),0,SURF));
// 	surf=csdf_sect(surf,csdf_sphere(c-vec3(0,3.8,0),4,SURF));
// 	surf=csdf_sect(surf,csdf_sphere(c-vec3(0,-3.8,0),4,SURF));
// 	surf=csdf_sect(surf,csdf_plane(c-vec3(-0.8,0,0),vec3(-1,0,0),0,SURF));
// 	surf=csdf_union(surf,csdf_diff(
// 		csdf_diff(
// 			csdf_cylinder_y(c-vec3(-0.7,0,-0.07),0.002,0.2,SURF),
// 			csdf_cylinder_y(c-vec3(-0.8,0,-0.12),0.1,0.17,SURF)),
// 		csdf_plane(c,-vec3(0,0,1),-0.04,SURF)));
// 	return surf; }


csd_t csdf_surf(vec3 c) {
	sd_t surf=sdf_sphere(c-vec3(0,0,8-0.1),8);
	surf=sdf_diff(surf,sdf_plane(c-vec3(0,0,-7.9+8-0.1),vec3(0,0,-1),0));
	surf=sdf_sect(surf,sdf_sphere(c-vec3(0,3.8,0),4));
	surf=sdf_sect(surf,sdf_sphere(c-vec3(0,-3.8,0),4));
	surf=sdf_sect(surf,sdf_plane(c-vec3(-0.8,0,0),vec3(-1,0,0),0));
	surf=sdf_union(surf,sdf_diff(
		sdf_diff(
			sdf_cylinder_y(c-vec3(-0.7,0,-0.07),0.002,0.2),
			sdf_cylinder_y(c-vec3(-0.8,0,-0.12),0.1,0.17)),
		sdf_plane(c,-vec3(0,0,1),-0.04)));
	return csd_t(surf,SURF); }


csd_t csdf_scene(vec3 p,bool displaced) {
	const float WAVE_WIDTH=8;
	const float WAVE_SPEED=0.70;
	const float WAVE_RANGE=64;
	const float MIN_HEIGHT=0;
	const float MAX_HEIGHT=40;
	const float MIN_LENGTH=0;
	const float MAX_LENGTH=120;
	sd_t sd=SDF_CLEAR;
	float t1=fract(WAVE_SPEED*time/24);
	float mod=(-cos(2*(t1*PI))+1)/2;
	mod=t1;
	const float one4=1.0/4;
	vec3 cell_size=vec3(0.5*one4,0.5*one4,0.2*one4);
	vec3 c=vec3(0,0,0.2*one4);
	sd_t wave=SDF_CLEAR;
	vec3 wave_center=vec3(mix(-WAVE_RANGE/2,WAVE_RANGE/2,t1),0,0);
	sd=sdf_plane(p,vec3(0,0,1),0);
	c=p-wave_center;
	float back_length=2*mix(MIN_LENGTH,MAX_LENGTH,mod);
	float front_length=mix(MIN_LENGTH,MAX_LENGTH,mod);
	float height=mix(MIN_HEIGHT,MAX_HEIGHT,mod);

	// WAVE CREST //
	float ct=2*max(0,height/front_length-0.5);
	ct=(1+sin(time*0.7))/2;
	ct=clamp(flat_step(0.4,0.7,t1+0.2*cos(p.y/WAVE_WIDTH)),0,1);
	// ct=clamp(t1+p.y/44,0,1);
	float crest_length=mix(0.0,3.0,ct);
	crest_length=min(crest_length,2.3);
	float crest_thickness=0.1;
	float lip_t=-2*crest_length+PI;
	vec2 wave_lip=vec2(
		0.5*height+0.5*cos(lip_t)*height-0.5*crest_thickness,
		height+0.5*sin(lip_t)*height-crest_thickness);
	vec2 wave_peak=vec2(
		0.5*height+0.5*cos(-2*min(crest_length,PI/6)+PI)*(height+crest_thickness)-0.5*crest_thickness,
		height+0.5*sin(-2*min(crest_length,PI/6)+PI)*(height+crest_thickness)-crest_thickness);
	sd_t wave_crest=sdf_arc(
		mat2_rotate(crest_length)*vec2(-c.z+height-1*crest_thickness,-c.x+height/2-crest_thickness/2),
		vec2(cos(crest_length),sin(crest_length)),
		height/2,
		crest_thickness);
	wave=sdf_smooth_union(wave,wave_crest,0.0);

	// TUNNEL //
	sd_t tunnel=sdf_cylinder_y(c-vec3(front_length/2-0.5*crest_thickness,0,height-crest_thickness),1000,front_length/2-0.5*crest_thickness);
	sd_t foam_bounds=sdf_cylinder_y(c-vec3(wave_lip.x,0,wave_lip.y),1000,0.6*pow(ct,0.6));
	// sd=sdf_union(sd,tunnel);

	// WAVE TROUGH //
	sd_t wave_trough=sdf_box(c-vec3(front_length/2,0,height/2),vec3(front_length/2,1000,height/2));
	sd_t trough_curvature=sdf_ellipse(c.zx-vec2(height,front_length),vec2(height,front_length));
	wave_trough=sdf_diff(wave_trough,trough_curvature);
	// wave_trough=sdf_isosceles_triangle(c.zx+vec2(height,-front_length*2),vec2(2*height,-front_length*2));
	// wave_trough=trough_curvature;
	// sd=sdf_union(sd,sdf_diff(wave_trough,tunnel));
	wave=sdf_union(wave,wave_trough);
	// wave_trough=SDF_CLEAR;

	// WAVE BACK //
	// vec2 wave_peak=vec2(front_length,0);
	sd_t wave_back=sdf_isosceles_triangle(c.zx+vec2(height,back_length*2),vec2(2*height,back_length*2));
	sd_t wave_extra_back=sdf_isosceles_triangle(
		c.zx+vec2(wave_peak.y,back_length*2+wave_peak.x),
		vec2(2*wave_peak.y,2*back_length+2*wave_peak.x));
	wave=sdf_smooth_union(wave,wave_back,0.0);
	wave=sdf_smooth_union(wave,sdf_diff(wave_extra_back,tunnel),0.0);

	// sd=wave_trough; // TEMP
	// sd=sdf_diff(sd,sdf_plane(c,vec3(0,1,0),0));
	// sd=sdf_union(sd,wave);

	// sd=sdf_union(sd,sdf_sphere(p,10));

	csd_t csd=csd_t(sd,WATER);

	// csd=csdf_union(csd,csd_t(foam_bounds,FOAM));

	if (displaced) {
		csd=csdf_displace(csd,1-sea_octave(p.xy,SEA_SHARPNESS,SEA_CHOPPY),-0.1); }

	// REFERENCE CUBES //
	// csd=csdf_union(csd,csdf_box(p-vec3(4,0,0),vec3(0.5),DEV));
	// csd=csdf_union(csd,csdf_box(p-vec3(-4,0,0),vec3(0.5),DEV));
	// csd=csdf_union(csd,csdf_box(p-vec3(0,4,0),vec3(0.5),DEV));
	// csd=csdf_union(csd,csdf_box(p-vec3(0,-4,0),vec3(0.5),DEV));
	// csd=csdf_union(csd,csdf_box(p-vec3(0,0,4),vec3(0.5),DEV));
	// csd=csdf_union(csd,csdf_box(p-vec3(0,0,-4),vec3(0.5),DEV));

	// TEMP
	// csd=csdf_union(csd,csd_t(sdf_foam(p,foam_bounds,vec3(1,0,0),1*ct),FOAM));

	return csd; }