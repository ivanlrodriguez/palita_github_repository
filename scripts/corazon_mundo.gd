extends StaticBody2D
class_name corazon_mundo

signal toss_triggered(jugador_ref)

func _on_area_teleport_body_entered(body: Node2D) -> void:

	if body is mugre:
		body.is_in_corazon_mundo = true
		body.phase = PI
		body.snap_pos = body.global_position.normalized() * Vector2(500, 250)
		body.set_orbit_mode()
		body.enter_orbit_from_snap()
		body.add_to_group("mugre_teleport")
		particulas_intoxicacion_mugres()

func _on_area_teleport_body_exited(body: Node2D) -> void:
	if body is mugre:
		body.remove_from_group("mugre_teleport")


@onready var mugres_particles := $mugre_teleport

func particulas_intoxicacion_mugres():
	
	var points: PackedVector2Array = []
	
	for body in get_tree().get_nodes_in_group("mugre_teleport"):
		var mugre_pos = body.global_position
		var local_pos = mugres_particles.to_local(mugre_pos)
		points.append(local_pos)
	
	mugres_particles.emission_points = points
	mugres_particles.emitting = true

var dir_cardinal : String
func _on_area_repulsion_body_entered(body: Node2D) -> void:
	if body is RigidBody2D:
		var direction = global_position.direction_to(body.global_position).normalized()
		#var angle = direction.angle()
		#if angle > -PI/4 and angle <= PI/4:
			#dir_cardinal = "O"
		#elif angle > -3*PI/4 and angle <= -PI/4:
			#dir_cardinal = "S"
		#elif angle > PI/4 and angle <= 3*PI/4:
			#dir_cardinal = "N"
		#else:
			#dir_cardinal = "E"
		#
		#var toss_component = body.get_node_or_null("tossable_component")  # Match name or path
		#if toss_component and toss_component.has_method("on_toss_triggered"):
			#connect("toss_triggered", Callable(toss_component, "on_toss_triggered"))
			#toss_component.in_toss_area = true
			#emit_signal("toss_triggered", self)
		
		body.apply_impulse(direction*100)


func _on_area_repulsion_body_exited(body: Node2D) -> void:
	if body is RigidBody2D:
		pass
		#var toss_component = body.get_node_or_null("tossable_component")
		#if toss_component and toss_component.has_method("on_toss_triggered"):
			#disconnect("toss_triggered", Callable(toss_component, "on_toss_triggered"))
			#toss_component.in_toss_area = false
