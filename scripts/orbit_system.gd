extends Node2D

var orbiting_mugres: Array = []
var orbit_entry_queue: Array = []
var active := false

var mugre_orbit_scene := preload("res://scenes/mugre_orbiting.tscn")  # Set this in the editor or preload()

func _swap_to_pre_orbit(rigidbody_mugre: Node2D, orbit_data: Dictionary) -> void:
	# Instantiate the lightweight mugre
	var orbit_mugre = mugre_orbit_scene.instantiate() as mugre_orbiting
	orbit_mugre.global_position = orbit_data.entry_pos

	# Copy sprite variant and optional phase info
	var id = rigidbody_mugre.mugre_id
	var phase = rigidbody_mugre.phase
	if rigidbody_mugre.entered_through_corazon_mundo:
		orbit_mugre.is_in_pre_orbit = false

	orbit_mugre.setup(orbit_data, id, phase)

	# Replace in scene tree
	get_tree().current_scene.add_child.call_deferred(orbit_mugre)
	rigidbody_mugre.queue_free()

	# Register for centralized orbit updates
	orbiting_mugres.append(orbit_mugre)

func _process(delta: float) -> void:
	for orbiter in orbiting_mugres:
		orbiter.update_orbit(delta)
		orbiter.fall_chance = max(0, 2500 - orbiting_mugres.size())

var mugre_physics_scene := preload("res://scenes/mugre.tscn")

func unregister(orbit_mugre: Node2D) -> void:
	orbiting_mugres.erase(orbit_mugre)
	orbit_mugre.queue_free()

func fell_from_orbit(orbit_mugre: Node2D):
	# Unregister from orbit update loop
	unregister(orbit_mugre)

	# Spawn the RigidBody2D mugre
	var rigid_mugre = mugre_physics_scene.instantiate()
	rigid_mugre.global_position = orbit_mugre.global_position
	
	if orbit_mugre.mugre_id[0] == "s":
		rigid_mugre.setup("small")
	else:
		rigid_mugre.setup("medium")
	rigid_mugre.nmugre = orbit_mugre.mugre_id[1]

	
	rigid_mugre.set_rigid_mode()
	get_tree().current_scene.add_child(rigid_mugre)
	var rand_angle = randf_range(0, TAU)
	rigid_mugre.apply_impulse(Vector2.from_angle(rand_angle) * randf_range(10, 100))
	#await get_tree().create_timer(1.0).timeout
	#rigid_mugre.set_passive_mode()
