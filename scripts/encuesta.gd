extends Control


func _ready() -> void:
	visible = false

var time: float
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if visible:
		time += Time.get_ticks_msec() / 1000
		var time_left = round(clamp(30 - time, 30, 0))
		$MarginContainer/VBoxContainer/Continue.text = "seguir jugando %s" % [time_left]
		if time_left == 0:
			$MarginContainer/VBoxContainer/Continue.text = "seguir jugando"
			$MarginContainer/VBoxContainer/Continue.disabled = false


func _on_continue_pressed() -> void:
	set_process(false)
