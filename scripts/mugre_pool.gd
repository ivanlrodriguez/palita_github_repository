extends Node
class_name MugrePool

# The pooled mugres
var orbit: Array = []
var rigid: Array = []

# Scene references
var orbit_scene := preload("res://scenes/mugre_orbiting.tscn")

func _ready():
	for i in range(3500):
		var orbit_body = orbit_scene.instantiate()
		orbit_body.visible = false
		orbit_body.global_position = Vector2(-9999, -9999)
		add_child(orbit_body)
		orbit.append(orbit_body)


func get_orbit_mugre() -> Node2D:
	if orbit.is_empty():
		push_error("⚠️ Orbit pool empty! Increase pool size.")
		return null
	return orbit.pop_back()

func get_rigid_mugre() -> Node2D:
	if rigid.is_empty():
		push_error("⚠️ Rigid pool empty! Consider fallback logic.")
		return null
	return rigid.pop_back()

func return_to_pool(node: Node2D) -> void:
	node.visible = false
	node.reset()
	
	if node is mugre:
		node.set_passive_mode()
		node.global_position = Vector2(-9999, -9999)
		rigid.append(node)
		print(rigid.size())
	elif node is mugre_orbiting:
		node.global_position = Vector2(-9999, -9999)
		orbit.append(node)
	else:
		push_error("⚠️ Unknown mugre type passed to pool.")

var mugres_to_despawn: Array = []
var is_despawning := false

func request_despawn(body: Node) -> void:
	if is_instance_valid(body):
		if body is mugre:
			body.set_invisible_mode()
		mugres_to_despawn.append(body)
		if not is_despawning:
			_start_staggered_despawn()

func _start_staggered_despawn() -> void:
	is_despawning = true
	_process_next_despawn()

func _process_next_despawn() -> void:
	if mugres_to_despawn.is_empty():
		is_despawning = false
		return

	var body = mugres_to_despawn.pop_back()
	if is_instance_valid(body):
		call_deferred("_finalize_despawn", body)

	# Schedule next despawn after 1 frame
	await get_tree().process_frame
	_process_next_despawn()

func _finalize_despawn(body: Node) -> void:
	if is_instance_valid(body):
		body.queue_free()


#var mugres_to_respawn: Array = []  # Each item is a Dictionary: { "source": Node, "callback": Callable }
#var is_respawning := false
#
#func request_respawn(source: Node, callback: Callable) -> void:
	#if is_instance_valid(source):
		#mugres_to_respawn.append({ "source": source, "callback": callback })
		#if not is_respawning:
			#_start_staggered_respawn()
#
#func _start_staggered_respawn() -> void:
	#is_respawning = true
	#_process_next_respawn()
#
#func _process_next_respawn() -> void:
	#if mugres_to_respawn.is_empty():
		#is_respawning = false
		#return
#
	#var item = mugres_to_respawn.pop_front()
	#var source = item.source
	#var callback = item.callback
#
	#call_deferred("_finalize_respawn", source, callback)
#
	#await get_tree().process_frame
	#_process_next_respawn()
#
#func _finalize_respawn(source: Node, callback: Callable) -> void:
	#var result: Node2D = null
#
	#if source is mugre:
		#if rigid.is_empty():
			#push_error("⚠️ Rigid pool empty!")
			#callback.call(null)
			#return
		#result = rigid.pop_back()
	#elif source is mugre_orbiting:
		#if rigid.is_empty():
			#push_error("⚠️ Rigid pool empty!")
			#callback.call(null)
			#return
		#result = rigid.pop_back()
#
	#if result:
		#result.visible = true
		#callback.call(result)
