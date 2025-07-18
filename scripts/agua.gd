extends RigidBody2D
class_name agua

signal agua_toco_piso_signal(agua_ref)
signal reproducir_pasto_signal(ref)

var origin_position_y : float
var piso_threshold : float
var toco_piso := false
var in_copa := false # ver _on_area_copa_body_entered() en jugador

func set_passive_mode():
	set_deferred("freeze", true)
	set_physics_process(false)
	set_process(false)

func reset():
	set_deferred("freeze", false)
	set_physics_process(true)
	set_process(true)
	visible = true
	z_index = 4
	#z_as_relative = false
	#y_sort_enabled = false
	randomize()
	origin_position_y = global_position.y
	piso_threshold = randf_range(12.0, 15.0)
	rotation = randf_range(0, PI)
	var nagua = randi_range(1, 7)
	var agua_sel: String = "agua_" + str(nagua)
	$agua_anim.play(agua_sel)
	$sfx_spawn.play()

func _ready() -> void:
	set_passive_mode()

func cuando_toca_piso():
	var actual_position_y = global_position.y
	if actual_position_y - origin_position_y > piso_threshold:
		toco_piso = true
		z_index = 0
		set_passive_mode()
		$agua_anim.play('agua_splash')
		$sfx_splash.play()
		$collsh_agua.disabled = true
		gravity_scale = 0.0
		rotation = 0.0
		$agua_anim.rotation_degrees = -16
		$agua_anim.skew = -45.0
		$agua_anim.scale = Vector2(2, 2)
		$agua_anim.position = Vector2(-0.5, -0.5)
		emit_signal("agua_toco_piso_signal", self)
		var chance_invocar_pasto = randi_range(0, 200)
		if chance_invocar_pasto == 0:
			emit_signal("reproducir_pasto_signal", self)


func _physics_process(_delta: float):
	if in_copa:
		return
	elif not toco_piso:
		cuando_toca_piso()
	else:
		set_physics_process(false)

var frame_count := 0
func _process(delta: float) -> void:
	frame_count += 1
	if frame_count >= randi_range(1, 300):
		frame_count = 0
		var nagua = randi_range(1, 7)
		var agua_sel: String = "agua_" + str(nagua)
		$agua_anim.play(agua_sel)
