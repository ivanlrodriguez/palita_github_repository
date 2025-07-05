extends StaticBody2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().create_timer(2.0)
	set_collision_layer_value(8, false)
	await get_tree().create_timer(2.0)
	set_collision_layer_value(8, true)
