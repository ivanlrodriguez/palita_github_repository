extends Control

@onready var world = get_node("/root")
@onready var menu = get_parent()

func _ready() -> void:
	visible = false
	$MarginContainer/VBoxContainer/Continue.disabled = true
	$MarginContainer/VBoxContainer/Continue.visible = false




func _process(_delta: float) -> void:
	# Show remaining time (in seconds, rounded to 1 decimal place)
	$MarginContainer/VBoxContainer/Continue.text = "quiero la experiencia sonora completa! (" + str("%.1f" % $timer_continuar.time_left) + ')'

func _on_timer_continuar_timeout() -> void:
	set_process(false)
	$MarginContainer/VBoxContainer/Continue.text = "quiero la experiencia sonora completa!"
	$MarginContainer/VBoxContainer/Continue.disabled = false


func _on_link_encuesta_pressed() -> void:
	OS.shell_open("https://docs.google.com/forms/d/e/1FAIpQLScJ4bcMHSs-N1fvDmrRzhKviTmvMlFx1DOPW0Uwal1hh6NkqA/viewform?usp=header")
	$MarginContainer/VBoxContainer/Label2.text = "si el boton no anduvo, el link está en los comentarios"
	$MarginContainer/VBoxContainer/link_encuesta.visible = false
	$MarginContainer/VBoxContainer/Continue.visible = true
	$timer_continuar.start()

func _on_continue_pressed() -> void:
	visible = false
	menu.esc_block = false
	menu.restore_mixer()
	await get_tree().create_timer(5.0).timeout
	if menu.modo_sonido != menu.Modo.MUSIC:
		$"../../music/musica_extended".play()
	else:
		$"../../ambient/wisdoms_tragedy".play()
		$"../../Timer_musica".start()
	if menu.modo_sonido == menu.Modo.SILENT:
		$"../main_menu/mixer".visible = true
