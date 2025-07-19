extends Area2D

func _on_body_entered(body: Node2D) -> void:
	if is_instance_valid(body):
		if body is mugre and not body.reciclada:
			body.enter_orbit_system()
