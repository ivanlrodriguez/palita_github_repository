extends Node
class_name MugreManager

var mugres_to_despawn: Array = []
var is_despawning := false

func request_despawn(body: Node) -> void:
	if is_instance_valid(body):
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

	var body = mugres_to_despawn.pop_front()
	if is_instance_valid(body):
		call_deferred("_finalize_despawn", body)

	# Schedule next despawn after 1 frame
	await get_tree().process_frame
	_process_next_despawn()

func _finalize_despawn(body: Node) -> void:
	if is_instance_valid(body):
		body.queue_free()
