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
@onready var despawn_check: Area2D = $despawn_check

var collsh: CollisionShape2D
var ntype: String
var nmugre: int
var mugre_id := ['s', 1]

var tossed := false
var being_pulled := false
var entered_through_corazon_mundo := false
var reciclada := false
var phase := 0.0

func reset():
	set_passive_mode()
	reciclada = false
	being_pulled = false
	entered_through_corazon_mundo = false
	z_index = 2
	gravity_scale = 0
	set_collision_layer_bit(2, true)
	set_collision_mask_bit(1, true)
	set_collision_mask_bit(2, true)

func setup(type: String):
	
	reset()
	
	if type == "small":
		ntype = "s"
		mass = 0.25
		$collmugre_s.set_deferred("disabled", false)
		collsh = $collmugre_s
		# desactivar la otra opcion
		$collmugre_m.set_deferred("disabled", true)
		$sfx_toco_piso.pitch_scale = 1.2
		
	elif type == "medium":
		ntype = "m"
		mass = 0.5
		$collmugre_m.set_deferred("disabled", false)
		collsh = $collmugre_m
		# desactivar la otra opcion
		$collmugre_s.set_deferred("disabled", true)
		$sfx_toco_piso.pitch_scale = 0.8

func _ready():
	randomize()
	nmugre = randi_range(1, 12)
	mugre_id = [ntype, nmugre]
	rotation = randf_range(0, TAU)
	sprite.play(ntype+ "_" + str(nmugre))
	despawn_check.set_deferred("monitoring", true)
	await get_tree().create_timer(0.2).timeout
	despawn_check.set_deferred("monitoring", false)
	if current_mode != MugreMode.PASSIVE and not reciclada:
		set_passive_mode()

func _on_despawn_check_body_entered(body: Node2D) -> void:
	if body is mugre:
		set_rigid_mode()
		await get_tree().create_timer(0.1).timeout
		if is_instance_valid(self):
			if current_mode != MugreMode.PASSIVE and not reciclada:
				set_passive_mode()
				despawn_check.set_deferred("monitoring", false)
	elif body is corazon_mundo:
		entered_through_corazon_mundo = true
		enter_orbit_system()
	else:
		reciclada = true
		mugre_pool.return_to_pool(self)


# --- Mode switching ---

func set_collision_layer_bit(layer: int, enabled: bool) -> void:
	if enabled:
		collision_layer |= 1 << (layer - 1)  # Turn ON bit
	else:
		collision_layer &= ~(1 << (layer - 1))  # Turn OFF bit


func set_collision_mask_bit(layer: int, enabled: bool) -> void:
	if enabled:
		collision_mask |= 1 << (layer - 1)
	else:
		collision_mask &= ~(1 << (layer - 1))


func set_passive_mode():
	current_mode = MugreMode.PASSIVE
	set_deferred("freeze", true)

func set_rigid_mode():
	current_mode = MugreMode.RIGID
	set_deferred("freeze", false)

func set_invisible_mode():
	sprite.visible = false
	set_passive_mode()
	global_position = Vector2(-9999.0, -9999.0)


func enter_orbit_system():
	var entry_pos := global_position
	var snap_pos: Vector2
	if entered_through_corazon_mundo:
		orbit_data = {
			"entry_pos": entry_pos,
			"velocity": Vector2.ZERO,
			"snap_pos": global_position.normalized() * Vector2(570, 300),
			"launch_time": 0.0,
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

func play_sfx_toco_piso():
	$sfx_toco_piso.play()
