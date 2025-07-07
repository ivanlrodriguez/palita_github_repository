extends Control


func _on_listo_pressed() -> void:
	visible = false
	$"../main_menu".visible = true


func _on_prueba_sonido_pressed() -> void:
	$MarginContainer/botones/menu_click.play()
	if $MarginContainer/VBoxContainer/listo.disabled:
		$MarginContainer/VBoxContainer/listo.disabled = false


func _on_prueba_sonido_toggled(toggled_on: bool) -> void:
	if toggled_on:
		$sound_test/sfx_pasos_standing.play()
	else:
		$sound_test/sfx_pasos_standing.stop()


func _on_sfx_pasos_standing_finished() -> void:
	$sound_test/sfx_pasos_standing.play()
