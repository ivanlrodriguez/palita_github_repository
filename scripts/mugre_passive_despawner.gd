extends Area2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().create_timer(3.0).timeout
	$collpol_inner_left.disabled = true
	$collpol_inner_right.disabled = true
	$collpol_area_hueco.disabled = true
	$collpol_piso_recicladora2.disabled = true
	$collpol_piso_galpon2.disabled = true

func _on_body_entered(body: Node2D) -> void:
	if is_instance_valid(body):
		if body is mugre:
			mugre_pool.return_to_pool(body)
