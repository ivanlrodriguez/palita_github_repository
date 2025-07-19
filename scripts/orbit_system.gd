extends Node2D

var orbiting_mugres: Array = []

func _swap_to_pre_orbit(rigid_mugre: Node2D, orbit_data: Dictionary) -> void:
	if is_instance_valid(rigid_mugre):
		# Instantiate the lightweight mugre
		var orbit_mugre = mugre_pool.get_orbit_mugre()
		var id = rigid_mugre.mugre_id
		var phase = rigid_mugre.phase
		if orbit_mugre:
			orbit_mugre.is_in_pre_orbit = !rigid_mugre.entered_through_corazon_mundo
			orbit_mugre.visible = true
			orbit_mugre.global_position = orbit_data.entry_pos
			orbit_mugre.setup(orbit_data, id, phase)
		
		
		mugre_pool.return_to_pool(rigid_mugre)
		
		# Register for centralized orbit updates
		orbiting_mugres.append(orbit_mugre)
		update_fall_chance()


func update_fall_chance():
	var rand_mugre_index = randf_range(0, orbiting_mugres.size())
	var rand_mugre = orbiting_mugres[rand_mugre_index]
	rand_mugre.fall_chance = max(0, round(float(1000 - orbiting_mugres.size()) / 100))
	print(rand_mugre.fall_chance)


func _process(delta: float) -> void:
	for orbiter in orbiting_mugres:
		orbiter.update_orbit(delta)



func fell_from_orbit(orbit_mugre: Node2D):
	# Spawn the rigid2D mugre
	var rigid_mugre = mugre_pool.get_rigid_mugre()
	if rigid_mugre:
		rigid_mugre.nmugre = orbit_mugre.mugre_id[1]
		if orbit_mugre.mugre_id[0] == "s":
			rigid_mugre.setup("small")
		else:
			rigid_mugre.setup("medium")
		rigid_mugre.global_position = orbit_mugre.global_position
		rigid_mugre.visible = true
		rigid_mugre.set_passive_mode()
		rigid_mugre.play_sfx_toco_piso()
		
		mugre_pool.return_to_pool(orbit_mugre)
		orbiting_mugres.erase(orbit_mugre)
		update_fall_chance()
		#await get_tree().process_frame
		#if is_instance_valid(rigid_mugre):
			#var rand_angle = randf_range(0, TAU)
			#rigid_mugre.apply_impulse(Vector2.from_angle(rand_angle) * randf_range(10, 100))
		#await get_tree().create_timer(0.5).timeout
		#if is_instance_valid(rigid_mugre):
			#rigid_mugre.set_passive_mode()
	
	
