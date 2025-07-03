extends Node

var mugres_to_despawn: Array = []

func request_despawn(body: Node) -> void:
	if is_instance_valid(body) and not mugres_to_despawn.has(body):
		mugres_to_despawn.append(body)

func _physics_process(_delta: float) -> void:
	if mugres_to_despawn.is_empty():
		return

	var to_despawn_now := mugres_to_despawn.duplicate()
	mugres_to_despawn.clear()

	for body in to_despawn_now:
		if is_instance_valid(body):
			# Wait 1 frame to ensure all set_deferred calls complete
			call_deferred("_finalize_despawn", body)

func _finalize_despawn(body: Node) -> void:
	if is_instance_valid(body):
		await get_tree().process_frame
		body.queue_free()
