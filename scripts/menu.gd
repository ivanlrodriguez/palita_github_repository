extends CanvasLayer

@export var prueba_sonido: bool = false

@onready var vbox = $main_menu/botones
@onready var btn_start = vbox.get_node("Start")
@onready var btn_continue = vbox.get_node("Continue")
@onready var btn_controls = vbox.get_node("Controls")
@onready var btn_options = vbox.get_node("Options")
@onready var controls_screen = $main_menu/controles
@onready var options_menu = $main_menu/opciones
@onready var camara = get_node("/root/mundo/jugador/Camera2D")
@onready var player = get_node("/root/mundo/jugador")

var game_started = false

func _ready():
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), -64.0)
	set_process(false)
	$main_menu.visible = false
	$encuesta.visible = false
	btn_continue.visible = false
	btn_controls.visible = false
	btn_options.visible = false
	$pantalla_de_carga.visible = true
	await get_tree().create_timer(10.0).timeout
	$pantalla_de_carga.visible = false
	if prueba_sonido:
		$main_menu.visible = false
		$sound_test.visible = true
	else:
		$main_menu.visible = true
	

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		visible = !visible
		toggle_pause()

func toggle_pause():
	get_tree().paused = !get_tree().paused

func _on_start_pressed():
	$menu_click.play()
	game_started = true
	btn_continue.visible = true
	btn_controls.visible = true
	btn_options.visible = true
	btn_start.visible = false
	visible = false
	get_tree().paused = false
	player.intro_block = true
	await get_tree().create_timer(3.0).timeout
	$intro_whoosh.play()
	var tween_zoom := create_tween()
	tween_zoom.tween_property(camara, "zoom", Vector2(5.0, 5.0), 15.0) \
	 .set_trans(Tween.TRANS_SINE) \
	 .set_ease(Tween.EASE_IN_OUT)
	await get_tree().create_timer(15.0).timeout
	player.intro_block = false



func _on_continue_pressed():
	$menu_click.play()
	visible = false
	toggle_pause()


func _on_controls_pressed():
	$menu_click.play()
	controls_screen.show()

func _on_options_pressed():
	$menu_click.play()
	options_menu.show()
