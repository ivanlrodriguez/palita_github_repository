extends StaticBody2D

signal reciclar_signal(mugre_ref)

func _ready() -> void:
	var mundo = get_parent()
	connect("reciclar_signal", Callable(mundo, "_on_reciclar"))

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
