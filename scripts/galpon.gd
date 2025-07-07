extends StaticBody2D


func _ready() -> void:
	await get_tree().create_timer(1.5).timeout
	$collpol.set_deferred('disabled', false)
