extends AnimatedSprite2D
class_name mugre_orbiting

var orbit_data: Dictionary
var sprite: AnimatedSprite2D
var mugre_id: Array
var phase := 0.0

var is_in_pre_orbit := false
var pre_orbit_timer := 0.0
var entry_pos := Vector2.ZERO
var snap_pos := Vector2.ZERO
var velocity := Vector2.ZERO
var center := Vector2.ZERO
var launch_time := 0.4
var t := 0.0
var t0 := 0.0
var a := 0.0
var b := 0.0
var t_cross_x := 0.0
var speed := 0.0
var wiggle_vector := Vector2.ZERO
var wiggle_damping := 4.0

# Orbit-only variables
var orbit_start_time := 0.0
var time_now := 0.0
var in_top_side := true
var half_cycle_time := 0.0
var defined_half_cycle_time := false
var registered_cycle_start := false
var last_cycle_time := 0.0

# Fall
var is_falling := false
var fall_speed := 0.0
var fall_duration := 0.6
var fall_start_pos_y := 0.0
var fall_target_pos_y := 0.0

func setup(data: Dictionary, id: Array, initial_phase: float = 0.0):
	orbit_data = data
	mugre_id = id
	phase = initial_phase

	# Set pre-orbit values
	entry_pos = data.entry_pos
	snap_pos = data.snap_pos
	velocity = data.velocity
	launch_time = data.launch_time
	pre_orbit_timer = 0.0
	is_in_pre_orbit = true

	# Initial position
	global_position = entry_pos

func _ready():
	self.play(mugre_id[0] + "_" + str(mugre_id[1]))

var dice_timer := 0.0
var dice := 9999
var fall_chance := 9999

func update_orbit(delta: float) -> void:
	if is_in_pre_orbit:
		_update_pre_orbit(delta)
	elif is_falling:
		_update_fall(delta)
	else:
		_update_active_orbit(delta)
		_check_for_fall(delta)


func _update_pre_orbit(delta: float) -> void:
	pre_orbit_timer += delta
	var t_pre_orbit = clamp(pre_orbit_timer / launch_time, 0.0, 1.0)
	global_position = entry_pos.lerp(snap_pos, t_pre_orbit)
	if t_pre_orbit >= 1.0:
		_enter_orbit()

func _enter_orbit():
	is_in_pre_orbit = false
	orbit_start_time = time_now
	# Reset orbit tracking vars
	t = 0.0
	defined_half_cycle_time = false
	registered_cycle_start = false
	last_cycle_time = 0.0
	# calculate orbit + wiggle
	center = (snap_pos + Vector2.ZERO) / 2.0
	var entry_x = abs(snap_pos.x)
	a = clamp(entry_x / 900.0, 0.001, 1.0) * 450.0
	b = 350.0

	var dx = snap_pos.x - center.x
	var dy = snap_pos.y - center.y
	var cos_t0 = clamp(dx / a, -1.0, 1.0)
	var sin_t0 = clamp(dy / b, -1.0, 1.0)
	t0 = atan2(sin_t0, cos_t0)
	
	
	var direction = -sign(snap_pos.x)
	speed = randf_range(0.05, 0.1) * direction * 3
	t_cross_x = acos(clamp(-center.x / a, -1.0, 1.0))
	wiggle_vector = velocity.normalized() * 12

func _update_active_orbit(delta: float) -> void:
	
	time_now += delta
	t += delta * speed
	var angle = t + t0
	var c = center
	
	var base_pos = Vector2(
		c.x + a * cos(angle + phase),
		c.y + b * sin(angle + phase)
	)
	
	var wiggle: Vector2
	if wiggle_vector != Vector2.ZERO:
		var t_fraction = clamp(abs(t) * 10 / 1.0, 0.0, 1.0)
		var damping = exp(-wiggle_damping * t_fraction)
		wiggle = wiggle_vector * sin(t_fraction * PI * 4) * damping
	
	global_position = base_pos + wiggle
	
	# Z index logic
	var flip_angle = fmod(t0 + t_cross_x, TAU)
	var orbit_relative_angle = wrap_angle_to_pi(angle - flip_angle, entry_pos.x)
	
	if -sign(entry_pos.x) * orbit_relative_angle < 0:
		z_index = -1
		in_top_side = false
		registered_cycle_start = false
		if half_cycle_time > 10.0 and not defined_half_cycle_time:
			defined_half_cycle_time = true
	else:
		z_index = 10
		in_top_side = true
		if not defined_half_cycle_time:
			half_cycle_time = time_now - orbit_start_time
		elif not registered_cycle_start:
			last_cycle_time = time_now
			registered_cycle_start = true


func _check_for_fall(delta: float) -> void:
	dice_timer += delta
	if not defined_half_cycle_time:
		return
	randomize()
	if in_top_side and dice_timer > randf_range(half_cycle_time, half_cycle_time * 2):
		dice = randi_range(0, fall_chance)
		dice_timer = 0.0
	if dice == 0 and time_now - last_cycle_time > half_cycle_time * randf_range(0.3, 0.9):
		fall_to_ground()


func calculate_ground_target() -> float:
	var x2 = snap_pos.x
	var y2 = snap_pos.y
	var x = global_position.x
	var m = y2 / x2
	var y = m * x
	return y

func fall_to_ground():
	is_falling = true
	is_in_pre_orbit = false
	fall_start_pos_y = global_position.y
	fall_target_pos_y = calculate_ground_target()
	fall_speed = 150.0 

func _update_fall(delta: float):
	global_position.y += fall_speed * delta
	
	if global_position.y >= fall_target_pos_y:
		orbit_system.fell_from_orbit(self)

func wrap_angle_to_pi(angle: float, ref_x: float) -> float:
	return fmod((-sign(ref_x) * angle + PI + phase), TAU) - PI
