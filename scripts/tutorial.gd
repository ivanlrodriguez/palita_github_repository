extends CanvasLayer

@onready var controles_in_game: VBoxContainer = $controles_in_game

func _ready():
	visible = false
	controles_in_game.modulate.a = 0.0  # Fully transparent

func fade_in():
	visible = true
	var tween_fade_in := create_tween()
	tween_fade_in.tween_property(controles_in_game, "modulate:a", 1, 2.0) \
	 .set_trans(Tween.TRANS_SINE) \
	 .set_ease(Tween.EASE_IN_OUT)
	await tween_fade_in.finished
	await get_tree().create_timer(10.0).timeout
	var tween_fade_out := create_tween()
	tween_fade_out.tween_property(controles_in_game, "modulate:a", 0.0, 2.0) \
	 .set_trans(Tween.TRANS_SINE) \
	 .set_ease(Tween.EASE_IN_OUT)
	await tween_fade_out.finished
	visible = false
