extends StaticBody2D
class_name corazon_mundo

func _on_area_teleport_body_entered(body: Node2D) -> void:

	if body is mugre:
		#body.add_to_group("mugre_teleport")
		#particulas_intoxicacion_mugres()
		body.entered_through_corazon_mundo = true
		#body.enter_orbit_system()

func _on_area_teleport_body_exited(body: Node2D) -> void:
	if body is mugre:
		pass
		#body.remove_from_group("mugre_teleport")


@onready var mugres_particles := $mugre_teleport

func particulas_intoxicacion_mugres():
	
	var points: PackedVector2Array = []
	
	for body in get_tree().get_nodes_in_group("mugre_teleport"):
		var mugre_pos = body.global_position
		var local_pos = mugres_particles.to_local(mugre_pos)
		points.append(local_pos)
	
	mugres_particles.emission_points = points
	mugres_particles.emitting = true

var mugre_counter := 0
func _on_area_repulsion_body_entered(body: Node2D) -> void:
	if body is mugre:
		mugre_counter = max(0, mugre_counter + 1)
		if not body.entered_through_corazon_mundo and body.current_mode != body.MugreMode.RIGID:
			body.set_rigid_mode()
		if body.has_method('apply_impulse'):
			var direction = body.global_position.direction_to(global_position).normalized()
			body.apply_impulse(direction * 35)


var area_monitoring: bool
var flicker_timer := 0.0
var flicker_interval := 0.03  # every ~6 frames at 60fps

func _process(delta: float) -> void:
	flicker_timer += delta
	if flicker_timer >= flicker_interval:
		flicker_timer = 0.0
		area_monitoring = !area_monitoring
		$area_repulsion.set_deferred("monitoring", area_monitoring)
