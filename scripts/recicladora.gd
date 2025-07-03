extends StaticBody2D

signal reciclar_signal(mugre_ref)

func _ready() -> void:
	var mundo = get_parent()
	connect("reciclar_signal", Callable(mundo, "_on_reciclar"))

func _on_hueco_body_entered(body: Node2D) -> void:
	if body is mugre and is_instance_valid(body):
		body.reciclada = true
		if body.current_mode != body.MugreMode.RIGID:
			body.set_rigid_mode()
		if body.current_mode == body.MugreMode.RIGID:
			body.gravity_scale = 1


func _on_hueco_body_exited(body: Node2D) -> void:
	if body is mugre and is_instance_valid(body):
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
