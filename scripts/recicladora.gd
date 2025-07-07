extends StaticBody2D

signal reciclar_signal(mugre_ref)

var level := 0
var final_level := 7

var level_variants: Array[AudioStream] = []
@onready var sfx_level: AudioStreamPlayer2D = $sfx_level

func _ready() -> void:
	var root = get_parent()
	connect("reciclar_signal", Callable(root, "_on_reciclar"))
	for i in range(1, 8):
		var index := str(i).pad_zeros(3)
		level_variants.append(load("res://assets/sfx/recic_level-%s.ogg" % [index]))
	await get_tree().create_timer(1.5).timeout
	$collpol.set_deferred('disabled', false)
	$collpol_area_hueco.set_deferred('disabled', false)


func level_up():
	if level == final_level:
		return
	level += 1
	$cuerpo_anim.play('lvl_%d' % [level])
	sfx_level.stream = level_variants[level - 1]
	sfx_level.play()
	if level == final_level:
		await get_tree().create_timer(3.0).timeout
		$sfx_bomba_lista.play()
		$cuerpo_anim.play("bomba_lista")
		await get_tree().create_timer(3.0).timeout
		$cuerpo_anim.play("full")
		$sfx_construyendo.play()
		await get_tree().create_timer(10.0).timeout
		$cuerpo_anim.play("deploy")
		await get_tree().create_timer(10.0).timeout
		$cuerpo_anim.play("idle")

func _on_hueco_body_entered(body: Node2D) -> void:
	if body is mugre and is_instance_valid(body):
		body.reciclada = true
		body.tossed = false
		body.set_rigid_mode()
		body.gravity_scale = 1
		body.set_collision_layer_bit(8, true)
		body.set_collision_mask_bit(1, false)
		body.set_collision_mask_bit(2, false)
		body.set_collision_layer_bit(2, false)

func _on_despawner_body_entered(body: Node2D) -> void:
	if body is mugre and is_instance_valid(body):
		body.set_invisible_mode()
		emit_signal("reciclar_signal", body)
		await get_tree().create_timer(0.5).timeout
		$sfx_mugre.play()

func _on_cinta_body_entered(body: Node2D) -> void:
	if body is RigidBody2D:
		body.add_to_group('in_cinta')


func _on_cinta_body_exited(body: Node2D) -> void:
	if body is RigidBody2D:
		body.remove_from_group('in_cinta')

func _physics_process(_delta: float) -> void:
	var bodies_in_cinta = get_tree().get_nodes_in_group('in_cinta')
	for body in bodies_in_cinta:
		body.apply_impulse(Vector2.from_angle(PI/6) * 2)



func _on_area_sfx_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D and not $sfx_motor.playing:
		$sfx_motor.play()
		print('sfx play')

func _on_area_sfx_body_exited(body: Node2D) -> void:
	if body is CharacterBody2D:
		$sfx_motor.stop()
		print('sfx stop')

func _on_sfx_motor_finished() -> void:
	$sfx_motor.play()
