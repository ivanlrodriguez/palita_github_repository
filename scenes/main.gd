extends Node

@onready var boton_start = $CanvasLayer/MainMenu/VBoxContainer/StartButton
@onready var mundo = $mundo


func _ready() -> void:
	$CanvasLayer/MainMenu/VBoxContainer/StartButton.pressed.connect(_on_start_pressed)
	print($CanvasLayer/MainMenu/VBoxContainer)


func _on_start_pressed():
	mundo.intro()
	$CanvasLayer/MainMenu/VBoxContainer.visible =false
