extends StaticBody2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().create_timer(0.9).timeout
	#$collpol_inner_left.set_deferred("disabled", true)
	#$collpol_inner_right.set_deferred("disabled", true)
	process_mode = Node.PROCESS_MODE_DISABLED
