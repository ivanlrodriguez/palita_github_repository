extends CanvasLayer

enum Menu { MAIN, MIXER, CONTROLES }
enum Modo { MUSIC, SFX, SILENT }

@export var modo_sonido := Modo.SILENT
var prueba_sonido: bool = false
var esc_block: bool = true

@onready var camara = get_node("/root/mundo/jugador/Camera2D")
@onready var player = get_node("/root/mundo/jugador")

@onready var main_menu = $main_menu
@onready var main_menu_botones = $main_menu/botones
@onready var btn_start = $main_menu/botones/Start
@onready var btn_continue = $main_menu/botones/Continue
@onready var btn_controls = $main_menu/botones/Controls
@onready var btn_mixer = $main_menu/botones/Mixer
@onready var controls_screen = $main_menu/controles

@onready var mixer = $main_menu/mixer
@onready var master_label: Label = $main_menu/mixer/master_label
@onready var master_slider: HSlider = $main_menu/mixer/master_slider
@onready var music_label: Label = $main_menu/mixer/music_label
@onready var music_slider: HSlider = $main_menu/mixer/music_slider
@onready var ambient_label: Label = $main_menu/mixer/ambient_label
@onready var ambient_slider: HSlider = $main_menu/mixer/ambient_slider
@onready var sfx_label: Label = $main_menu/mixer/sfx_label
@onready var sfx_slider: HSlider = $main_menu/mixer/sfx_slider
@onready var gui_label: Label = $main_menu/mixer/gui_label
@onready var gui_slider: HSlider = $main_menu/mixer/gui_slider


@onready var encuesta: Control = $encuesta
@onready var sound_test: Control = $sound_test
@onready var pantalla_de_carga: Control = $pantalla_de_carga
@onready var tutorial = get_node("/root/mundo/tutorial")

@onready var menu_click: AudioStreamPlayer2D = $menu_click
@onready var intro_whoosh: AudioStreamPlayer2D = $intro_whoosh

@onready var musica_extended: AudioStreamPlayer2D = $"../music/musica_extended"
@onready var timer_prueba: Timer = $"../timer_prueba"


var game_started = false

func _ready():
	AudioServer.set_bus_mute(AudioServer.get_bus_index("SFX"), true)
	
	match_modo_sonido()
	
	set_process(false)
	
	esc_block = true
	
	main_menu.visible = false
	main_menu_botones.visible = true
	encuesta.visible = false
	tutorial.visible = false
	
	controls_screen.hide()
	mixer.hide()
	btn_continue.visible = false
	btn_controls.visible = false
	btn_mixer.visible = false
	
	pantalla_de_carga.visible = true
	await get_tree().create_timer(10.0).timeout
	pantalla_de_carga.visible = false
	if modo_sonido == Modo.SFX:
		AudioServer.set_bus_mute(AudioServer.get_bus_index("SFX"), false)
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), -64.0)
	
	
	if prueba_sonido:
		main_menu.visible = false
		sound_test.visible = true
	else:
		main_menu.visible = true


func match_modo_sonido():
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), 0.0)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), 0.0)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("music"), 0.0)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("music"), 0.0)
	master_label.visible = true
	master_slider.visible = true
	gui_label.visible = true
	gui_slider.visible = true
	music_label.visible = false
	music_slider.visible = false
	ambient_label.visible = false
	ambient_slider.visible = false
	sfx_label.visible = false
	sfx_slider.visible = false
	
	match modo_sonido:
		Modo.MUSIC:
			prueba_sonido = true
			music_label.visible = true
			music_slider.visible = true
			AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), 0.0)
			AudioServer.set_bus_volume_db(AudioServer.get_bus_index("music"), 0.0)
			AudioServer.set_bus_mute(AudioServer.get_bus_index("SFX"), true)
			AudioServer.set_bus_mute(AudioServer.get_bus_index("ambient"), true)
		Modo.SFX:
			AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), 0.0)
			AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), 0.0)
			AudioServer.set_bus_mute(AudioServer.get_bus_index("music"), true)
			prueba_sonido = true
			ambient_label.visible = true
			ambient_slider.visible = true
			sfx_label.visible = true
			sfx_slider.visible = true
			
		Modo.SILENT:
			AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), true)
			btn_mixer.visible = false
			prueba_sonido = false

func restore_mixer():
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), 0.0)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), 0.0)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("music"), 0.0)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("ambient"), 0.0)
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), false)
	AudioServer.set_bus_mute(AudioServer.get_bus_index("SFX"), false)
	AudioServer.set_bus_mute(AudioServer.get_bus_index("music"), false)
	AudioServer.set_bus_mute(AudioServer.get_bus_index("ambient"), false)
	btn_mixer.visible = true
	master_label.visible = true
	master_slider.visible = true
	gui_label.visible = true
	gui_slider.visible = true
	music_label.visible = true
	music_slider.visible = true
	ambient_label.visible = true
	ambient_slider.visible = true
	sfx_label.visible = true
	sfx_slider.visible = true


func _input(event):
	
	if event.is_action_pressed("ui_cancel"):
		if esc_block:
			return
		visible = !visible
		toggle_pause()
		main_menu.show()
		main_menu_botones.show()
		mixer.hide()
		controls_screen.hide()

func toggle_pause():
	get_tree().paused = !get_tree().paused

func _on_start_pressed():
	menu_click.play()
	if modo_sonido != Modo.SILENT:
		musica_extended.play()
	game_started = true
	timer_prueba.start()
	btn_continue.visible = true
	btn_controls.visible = true
	if modo_sonido != Modo.SILENT:
		btn_mixer.visible = true
	btn_start.visible = false
	visible = false
	get_tree().paused = false
	player.intro_block = true
	await get_tree().create_timer(3.0).timeout
	intro_whoosh.play()
	var tween_zoom := create_tween()
	tween_zoom.tween_property(camara, "zoom", Vector2(5.0, 5.0), 15.0) \
		.set_trans(Tween.TRANS_SINE) \
		.set_ease(Tween.EASE_IN)
	var tween_zoom_pos := create_tween()
	tween_zoom_pos.tween_property(camara, "position", Vector2(0.0, 0.0), 15.0) \
		.set_trans(Tween.TRANS_SINE) \
		.set_ease(Tween.EASE_IN)
	await get_tree().create_timer(15.0).timeout
	tutorial.fade_in()
	player.intro_block = false
	esc_block = false
	player.walk_stop()
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), 0.0)


func _on_continue_pressed():
	menu_click.play()
	visible = false
	toggle_pause()


func _on_controls_pressed():
	menu_click.play()
	controls_screen.show()
	main_menu_botones.hide()

func _on_cerrar_controles_pressed() -> void:
	menu_click.play()
	controls_screen.hide()
	main_menu_botones.show()

func _on_options_pressed():
	menu_click.play()
	mixer.show()
	main_menu_botones.hide()

func _on_cerrar_opciones_pressed() -> void:
	menu_click.play()
	mixer.hide()
	main_menu_botones.show()


# mixer
func _on_master_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), value)
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), value < 0.05)


func _on_music_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("music"), value)
	AudioServer.set_bus_mute(AudioServer.get_bus_index("music"), value < 0.05)


func _on_sfx_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), value)
	AudioServer.set_bus_mute(AudioServer.get_bus_index("SFX"), value < 0.05)


func _on_ambient_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("ambient"), value)
	AudioServer.set_bus_mute(AudioServer.get_bus_index("ambient"), value < 0.05)


func _on_gui_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("GUI"), value)
	AudioServer.set_bus_mute(AudioServer.get_bus_index("GUI"), value < 0.05)
