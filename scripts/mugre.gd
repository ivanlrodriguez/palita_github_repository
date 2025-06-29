extends RigidBody2D
class_name mugre

enum MugreMode { PASSIVE, RIGID }

var current_mode := MugreMode.PASSIVE

var orbit_data = {
	"entry_pos": Vector2.ZERO,
	"velocity": Vector2.ZERO,
	"snap_pos": Vector2.ZERO,
	"launch_time": 0.0,
}


@onready var sprite := $sprite
var collsh: CollisionShape2D
var ntype: String
var nmugre: int
var mugre_id: Array

var orbit_start_time := 0.0
var in_top_side = true
var tossed := false
var entered_through_corazon_mundo := false
var phase := 0.0


func setup(type: String):
	if type == "small":
		ntype = "s"
		mass = 0.25
		$collmugre_s.set_deferred("disabled", false)
		collsh = $collmugre_s
		# desactivar la otra opcion
		$collmugre_m.set_deferred("disabled", true)
		
	elif type == "medium":
		ntype = "m"
		mass = 0.5
		$collmugre_m.set_deferred("disabled", false)
		collsh = $collmugre_m
		# desactivar la otra opcion
		$collmugre_s.set_deferred("disabled", true)

func _ready():
	randomize()
	nmugre = randi_range(1, 12)
	mugre_id = [ntype, nmugre]
	rotation = randf_range(0, TAU)
	sprite.play(ntype+ "_" + str(nmugre))
	set_rigid_mode()
	await get_tree().create_timer(0.1).timeout
	set_passive_mode()


# --- Mode switching ---

#func set_collision_layer_bit(layer: int, enabled: bool) -> void:
	#if enabled:
		#collision_layer |= 1 << (layer - 1)  # Turn ON bit
	#else:
		#collision_layer &= ~(1 << (layer - 1))  # Turn OFF bit
#
#
#func set_collision_mask_bit(layer: int, enabled: bool) -> void:
	#if enabled:
		#collision_mask |= 1 << (layer - 1)
	#else:
		#collision_mask &= ~(1 << (layer - 1))


func set_passive_mode():
	current_mode = MugreMode.PASSIVE
	collsh.set_deferred("disabled", false)
	set_deferred('freeze_mode', 0)
	set_deferred("freeze", true)

func set_rigid_mode():
	current_mode = MugreMode.RIGID
	collsh.set_deferred("disabled", false)
	set_deferred("freeze", false)


func enter_orbit_system():
	var entry_pos := global_position
	var snap_pos: Vector2
	if entered_through_corazon_mundo:
		orbit_data = {
			"entry_pos": entry_pos,
			"velocity": Vector2.ZERO,
			"snap_pos": global_position.normalized() * Vector2(570, 300),
			"launch_time": 0.0
			}
		phase = PI
		orbit_system._swap_to_pre_orbit(self, orbit_data)
	else:
		var velocity : Vector2 = linear_velocity
		var min_speed := 100.0
		var max_speed := 400.0
		var clamped_speed : float = clamp(velocity.length(), min_speed, max_speed)

		velocity = velocity.normalized() * clamped_speed
		var launch_time := 1/(clamped_speed/100)  # time to reach snap point
		snap_pos = entry_pos + velocity * launch_time
		
		orbit_data = {
			"entry_pos": entry_pos,
			"velocity": velocity,
			"snap_pos": snap_pos,
			"launch_time": launch_time
			}
		orbit_system._swap_to_pre_orbit(self, orbit_data)

## --- Orbit simulation ---
#
#var time_now := 0.0
#var frame_count := 0
#var throw_dice := 0
#var dice := 9999
#var fall_chance := 9999
#var bodies_in_orbit := 0

#func _process(delta):
	#frame_count += 1
	#throw_dice += 1
	#if frame_count >= 2:
		#frame_count = 0
		#if is_in_pre_orbit:
			#pre_orbit_timer += delta
			#var t = clamp(pre_orbit_timer / launch_time, 0.0, 1.0)
			#global_position = entry_pos.lerp(snap_pos, t)
			#if t >= 1.0:
				## Orbit entry happens now
				#enter_orbit_from_snap()
		#elif is_in_orbit:
			#time_now += delta
			#update_orbit(delta)
			#if not defined_half_cycle_time:
				#return
			#if dice == 0 and time_now - last_cycle_time > half_cycle_time * randf_range(0.3, 0.95):
				#fall_to_ground()
				#return
			#if in_top_side and throw_dice >= 10:
				#dice = randi_range(0, fall_chance)
				#throw_dice = 0

#var pre_orbit_timer := 0.0

#var entry_pos := Vector2.ZERO
#var snap_pos := Vector2.ZERO
#var velocity := Vector2.ZERO
#var wiggle_vector := Vector2.ZERO
#var is_in_pre_orbit := false
#var is_in_orbit := false

#func start_pre_orbit(data: Dictionary):
	#current_mode = MugreMode.ORBITING
	#orbit_data = data
	#collsh.set_deferred("disabled", true)
	#set_deferred('freeze_mode', 0)
	#set_deferred("freeze", true)
	#set_process(true)
	#set_physics_process(false)
	#
	#entry_pos = data.entry_pos
	#velocity = data.velocity
	#snap_pos = data.snap_pos
	#launch_time = data.launch_time
	#pre_orbit_timer = 0.0
	#is_in_pre_orbit = true
#
#func enter_orbit_from_snap():
	##if current_mode != MugreMode.ORBITING:
		##current_mode = MugreMode.ORBITING
	##is_in_pre_orbit = false
	#var entry_time = time_now
	#orbit_start_time = entry_time
	## Compute orbit using snap_pos as entry
	## We'll generate orbit params here, simplified:
	#var center = (snap_pos + Vector2.ZERO) / 2.0
	#var entry_x = abs(snap_pos.x)
	#var a = clamp(entry_x / 900.0, 0.001, 1.0) * 450.0
	#var b = 350.0
#
	#var dx = snap_pos.x - center.x
	#var dy = snap_pos.y - center.y
	#var cos_t0 = clamp(dx / a, -1.0, 1.0)
	#var sin_t0 = clamp(dy / b, -1.0, 1.0)
	#var t0 = atan2(sin_t0, cos_t0)
	#
	#var direction = -sign(snap_pos.x)
	#var speed = randf_range(0.1, 0.4) * direction
	#var t_cross_x = acos(clamp(-center.x / a, -1.0, 1.0))
#
	## ✅ Wiggle vector matches the initial velocity direction
	#wiggle_vector = velocity.normalized() * randf_range(12.0, 24.0)
#
	#orbit_data = {
		#"entry_time": entry_time,
		#"center": center,
		#"a": a,
		#"b": b,
		#"t": 0.0,
		#"t0": t0,
		#"speed": speed,
		#"duration": randf_range(120.0, 160.0),
		#"entry_pos": snap_pos,
		#"t_cross_x": t_cross_x,
		#"wiggle_vector": wiggle_vector,
		#"wiggle_damping": 3.0
	#}
	#is_in_orbit = true
#
## NOTA: esta funcion es un bardo. no tengo idea como funciona, pero funciona
## los -sign(orbit_data.entry_pos.x) son un fix para que las mugres desaparezcan en el (0,0)
## sin importar si estan del lado positivo o negativo de X
## (el angulo empieza en 0 si x<0 pero empieza en 3,8 si x>0, no tengo idea de por qué
#
#var defined_half_cycle_time := false
#var half_cycle_time := 0.0
#var registered_cycle_start := false
#var last_cycle_time := 0.0
#
#func update_orbit(delta):
	#orbit_data.t += delta * orbit_data.speed
	#var angle = orbit_data.t + orbit_data.t0
	#var a = orbit_data.a
	#var b = orbit_data.b
	#var c = orbit_data.center
	#
	#var base_pos = Vector2(
		#c.x + a * cos(angle + phase),
		#c.y + b * sin(angle + phase)
	#)
#
	## Wiggle animation (damped sinusoid)
	#var t_fraction = clamp(abs(orbit_data.t)*3 / 1.0, 0.0, 1.0)
	#var damping = exp(-orbit_data.wiggle_damping * t_fraction)
	#var wiggle = orbit_data.wiggle_vector * sin(t_fraction * PI * 4) * damping
#
	#global_position = base_pos + wiggle
#
	## Use X-crossing as a z-flip point
	#var flip_angle = fmod(orbit_data.t0 + orbit_data.t_cross_x, TAU)
	## Normalize the difference between current angle and flip_angle to range [-PI, PI]
	#var orbit_relative_angle = wrap_angle_to_pi(angle - flip_angle, orbit_data.entry_pos.x)
	#
	## Flip z_index when mugre is "behind" world center
	#if -sign(orbit_data.entry_pos.x) * orbit_relative_angle < 0:
		#z_index = -1  # Behind
		#in_top_side = false
		#registered_cycle_start = false
		#if half_cycle_time > 10.0 and defined_half_cycle_time == false:
			#defined_half_cycle_time = true
	#else:
		#z_index = 10  # In front
		#in_top_side = true
		#if not defined_half_cycle_time:
			#half_cycle_time = time_now - orbit_start_time
		#elif not registered_cycle_start:
			#last_cycle_time = time_now
			#registered_cycle_start = true
