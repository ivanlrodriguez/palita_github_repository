extends Control

@onready var world = get_node("/root")

func _ready() -> void:
	visible = false
	$MarginContainer/VBoxContainer/Continue.disabled = true
	$MarginContainer/VBoxContainer/Continue.visible = false




func _process(_delta: float) -> void:
	# Show remaining time (in seconds, rounded to 1 decimal place)
	$MarginContainer/VBoxContainer/Continue.text = "seguir jugando! (" + str("%.1f" % $timer_continuar.time_left) + ')'

func _on_timer_continuar_timeout() -> void:
	set_process(false)
	$MarginContainer/VBoxContainer/Continue.text = "seguir jugando!"
	$MarginContainer/VBoxContainer/Continue.disabled = false


func _on_link_encuesta_pressed() -> void:
	OS.shell_open("https://docs.google.com/forms/d/e/1FAIpQLScJ4bcMHSs-N1fvDmrRzhKviTmvMlFx1DOPW0Uwal1hh6NkqA/viewform?usp=header")
	$MarginContainer/VBoxContainer/Label2.text = "si el boton no anduvo, el link está en los comentarios"
	$MarginContainer/VBoxContainer/link_encuesta.visible = false
	$MarginContainer/VBoxContainer/Continue.visible = true
	$timer_continuar.start()

func _on_continue_pressed() -> void:
	visible = false
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), 0.0)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), 0.0)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("music"), 0.0)
	await get_tree().create_timer(5.0).timeout
	$"../../music/musica_extended".play()
