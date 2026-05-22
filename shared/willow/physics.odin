#+feature using-stmt
package willow
// import "core:fmt"
// import "core:math"
// import "core:math/linalg"
// import "core:math/rand"
// import "core:slice"
// import gl "vendor:OpenGL"


// Physics :: struct {
// 	swimming:            bool,
// 	surfer_state:        Surfer_State,
// 	surfer_position:     [3]f32,
// 	surfer_velocity:     [3]f32,
// 	surf_velocity:       [3]f32,
// 	surf_position:       [3]f32,
// 	surf_direction:      [3]f32,
// 	surf_up_direction:   [3]f32,
// 	surf_side_direction: [3]f32,
// 	surf_orientation:    quaternion128,
// 	collision_surfaces:  [dynamic]SDF_Surface, // TODO: Why is this a pointer?
// 	collision_distance:  Distance,
// 	collision_normal:    [3]f32,
// 	d_surf:              f32,
// 	d_surf_displaced:    f32,
// 	d_surfer:            f32,
// 	n_surf:              [3]f32,
// 	n_surf_displaced:    [3]f32 }


// Meter::1
// Kilogram::1
// Second::1
// Gram::0.001*Kilogram
// Centimeter::0.01*Meter
// Centimeter2::Centimeter*Centimeter
// Centimeter3::Centimeter*Centimeter*Centimeter


// GRAVITY_ACCEL::1.0
// AIR_DENSITY::0.001293*(Gram/Centimeter3)
// WATER_DENSITY::1*(Gram/Centimeter3)
// SURFER_MASS::70*Kilogram
// SURF_MASS::20*Kilogram
// WORLD_SCALE::1*Meter
// WORLD_SCALE_2::WORLD_SCALE*WORLD_SCALE
// SPHERE_DRAG_COEFFICIENT::0.47
// SURF_DRAG_COEFFICIENT::0.04
// MAN_DRAG_COEFFICIENT::1.00
// SURFER_RADIUS::0.1
// SURF_RADIUS::0.2
// BUOY_RADIUS::0.05
// SWIMMING_SPEED::2


// sphere_buoyancy_force::proc(distance:f32,radius:f32)->(buoyancy_force:f32) {
// 	ratio:f32=clamp((-distance+2*radius)/(2*radius),0,1)
// 	displaced_volume:f32=ratio*(4*math.PI*radius*radius)
// 	return WATER_DENSITY*displaced_volume*GRAVITY_ACCEL }


// sphere_cross_section::proc(radius:f32)->(cross_section:f32) {
// 	return math.PI*radius*radius }


// sphere_drag_force::proc(fluid_density:f32,velocity:f32,radius:f32)->(drag_force:f32) {
// 	return 0.5*fluid_density*velocity*velocity*sphere_cross_section(radius)*SPHERE_DRAG_COEFFICIENT }


// drag_force::proc(fluid_density:f32,velocity:f32,cross_section:f32,drag_coefficient:f32)->(drag_force:f32) {
// 	return 0.5*fluid_density*velocity*velocity*cross_section*drag_coefficient }


// physics_init :: proc(physics: ^Physics, model_instances: ^[dynamic]Model_Instance) {
// 	// PARAMS //
// 	physics.swimming = false
// 	physics.surfer_state = .SWIMMING
// 	physics.surfer_position = { 0.0, 0.0, 5 }
// 	physics.surfer_velocity = { 0, 0, 0 }
// 	physics.surf_position = { rand.float32_range(-8, 8), rand.float32_range(-10, 10), 0.1 }
// 	physics.surf_direction = { -1, 0, 0 }
// 	physics.surf_up_direction = { 0, 0, 1 }
// 	physics.surf_side_direction = linalg.vector_cross3(physics.surf_direction, -physics.surf_up_direction)
// 	physics.surf_velocity = { 0, 0, 0 }
// 	physics.surf_orientation = linalg.quaternion_from_euler_angles_f32(0, 0, 0, .XYZ)
// 	physics.collision_surfaces = make([dynamic]SDF_Surface)

// 	// append(&physics.collision_surfaces,SDF_Sphere{ c={0.2,0,0},r=2.0 })

// 	// GROUND COLLIDER //
// 	search_proc :: proc(model_instance: Model_Instance) -> bool {
// 		return model_instance.model.name == "ground-collider" }
// 	index, found := slice.linear_search_proc(model_instances[:], search_proc)
// 	assert(found)
// 	ground_instance := &model_instances[index]
// 	ground_model := ground_instance.model
// 	for i in 0 ..< len(ground_model.positions) / 9 {
// 		a: [3]f32 = { ground_model.positions[9 * i + 0], ground_model.positions[9 * i + 1], ground_model.positions[9 * i + 2]}
// 		b: [3]f32 = { ground_model.positions[9 * i + 3], ground_model.positions[9 * i + 4], ground_model.positions[9 * i + 5]}
// 		c: [3]f32 = { ground_model.positions[9 * i + 6], ground_model.positions[9 * i + 7], ground_model.positions[9 * i + 8]}
// 		triangle: SDF_Triangle = {
// 			a = apply_transform(a, ground_instance.transform),
// 			b = apply_transform(b, ground_instance.transform),
// 			c = apply_transform(c, ground_instance.transform) }
// 		append(&physics.collision_surfaces, cast(SDF_Surface)triangle) } }


// Physics_Buffer_Channel::enum {
// 	D_SURF,
// 	D_SURF_DISPLACED,
// 	D_SURFER,
// 	N_SURF,
// 	N_SURF_DISPLACED }


// surfer_is_near_surf :: proc(physics: ^Physics) -> bool {
// 	return linalg.distance(physics.surf_position, physics.surfer_position) < 2 }


// Physics_Tick_Data :: struct {
// 	physics: ^Locked_Struct(Physics),
// 	clock:   ^Locked_Struct(Clock),
// 	camera:  ^Locked_Struct(Camera) }
// physics_tick_filters: Thread_Filters : { .MAIN_THREAD }
// @(tag="job") physics_tick :: proc(data_ptr: rawptr) {
// 	data := cast(^Physics_Tick_Data)data_ptr
// 	defer free(data)
// 	using data
// 	lock_guard(&camera.lock)
// 	lock_guard(&clock.lock)
// 	lock_guard(&physics.lock)
// 	// TEMP
// 	// walking_physics_tick(physics, clock, camera)
// }


// walking_physics_tick :: proc(physics: ^Physics, clock: ^Clock, camera: ^Camera) {

// 	fmt.println(physics.surfer_position)

// 	//----------------//
// 	// Observe  //
// 	epsilon:f32:0.01
// 	dt: f32 = clock.frame_rate_controller.tick_period_sec
// 	// dt:f32=PERIOD_240FPS_SEC
// 	// d:=sd_collision_surfaces(physics.surfer_position)
// 	// n:=n_collision_surfaces(physics.surfer_position)
// 	// physics.collision_distance=d
// 	// physics.collision_normal=n
// 	control_direction_planar: [3]f32 =linalg.normalize([3]f32{ camera.control_direction.x, camera.control_direction.y, 0})
// 	if physics.surfer_state == .PADDLING {
// 		physics.surf_direction = control_direction_planar
// 		physics.surf_up_direction = { 0, 0, 1 }
// 		physics.surf_side_direction = linalg.vector_cross3(physics.surf_direction, -physics.surf_up_direction) }
// 	initial_position: [3]f32 = physics.surfer_position

// 	//------------------------------------//
// 	// Estimate force without collisions. //
// 	force: [3]f32 = { 0, 0, 0 }
// 	mass: f32 = SURFER_MASS
// 	force += { 0, 0, -GRAVITY_ACCEL * SURFER_MASS }
// 	velocity: [3]f32 = physics.surfer_velocity + (force / mass) * dt

// 	//-------------------------------//
// 	// Correct force with collision. //
// 	estimated_position: [3]f32 = initial_position + velocity * dt
// 	estimated_distance: f32 = sdf_collision_surfaces(estimated_position, &physics.collision_surfaces)
// 	if estimated_distance < 0 {
// 		collision_normal: [3]f32 = nf_collision_surfaces(estimated_position, &physics.collision_surfaces)
// 		fmt.println("collision_normal:", collision_normal)
// 		fmt.println("initial_force:", force)
// 		fmt.println("projected_force:", linalg.projection(force, -collision_normal))
// 		fmt.println("updated_force:", force - linalg.projection(force, -collision_normal))
// 		force = force - linalg.projection(force, -collision_normal) }

// 	//--------------//
// 	// Apply force. //
// 	velocity = physics.surfer_velocity + (force / mass) * dt
// 	final_position: [3]f32 = initial_position + velocity * dt
// 	physics.surfer_position = final_position
// 	physics.surfer_velocity = velocity

// 	//-----------------//
// 	// Correct errors. //
// 	d := sdf_collision_surfaces(physics.surfer_position, &physics.collision_surfaces)
// 	n := nf_collision_surfaces(physics.surfer_position, &physics.collision_surfaces)
// 	if d < 0 {
// 		physics.surfer_position -= n * d }

// 	/*
// 	camera_position_pivot
// 	camera_zoom_pivot
// 	camera_position
// 	camera_zoom
// 	CAMERA_POS_RADIUS
// 	CAMERA_ZOOM
// 	*/
// 	//camera_pivot.xy+=dt*cursor_delta
// 	//camera_vel.xy+=coloumb(camera_position.xy,camera_pivot.xy,1)
// 	//camera_vel.xy*=(1.0-(1.0*dt))
// 	//camera_position.xy+=camera_vel.xy*dt
// 	// camera_position.xy=2*cursor/cast_array(resolution,f32)
// }


// bump_function::proc(t:f32,period:f32,amplitude:f32)->f32 {
// 	square:f32=in_range(t/period,0.0,0.5)?8.0:0.0
// 	tail:f32=t/period>0.5?amplitude:0.0
// 	// wave:f32=amplitude*math.pow_f32(math.E,-math.pow_f32(4*t/period-2,2))-0.01832
// 	// wave:f32=amplitude*2*t/period
// 	wave:f32=amplitude*(-math.abs(2*t/period-1)+1)
// 	return max(tail,max(square,wave)) }


// bump_function :: proc(t: f32, period: f32, amplitude: f32) -> f32 {
// 	// wave:f32=amplitude*math.pow(math.E,-math.pow_f32(2.5*(t/period-0.2)-2.0,2.0))
// 	wave: f32 = amplitude * (-math.abs(1.5 * (t / period - 1)) + 1)
// 	tail: f32 = t / period > 1 ? amplitude : 0.0
// 	hint: f32 = 8 * math.pow(math.E, -math.pow_f32(16 * t / period - 2.0, 2.0))
// 	return max(tail, max(hint, wave)) }


// bumps :: proc() -> f32 {
// 	@(static) bump_queue:[dynamic]Bump
// 	acc: f32 = 0.0
// 	for bump in bump_queue {
// 		acc += bump_function(net_time - bump.offset, bump.period, bump.amplitude) }
// 	return acc }


// How the physics works:
// * the entire physics geometry is defined by an array of SDFs.
// * the SDFs are generated from the meshes after they are imported.
// * every mesh must that you want to have physics must be paired with convex hulls named '<mesh-name>-collider<hull-index>'.
// * the ground doesn't need a convex hull but it's collider has to be a triangulated plane named 'ground-collider'.
// * every collider has a spherical bound defined by an origin point and a radius, used for culling.


// Ground_Collider::struct {
// 	triangles:[][3][2]f32, // Store only X and Y
// 	sdfs:[]SDF_Plane }

