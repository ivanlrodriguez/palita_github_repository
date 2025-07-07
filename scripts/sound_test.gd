extends Control


func _on_listo_pressed() -> void:
	visible = false
	$"../main_menu".visible = true


func _on_prueba_sonido_pressed() -> void:
	$"../menu_click".play()
	if $MarginContainer/VBoxContainer/listo.disabled:
		$MarginContainer/VBoxContainer/listo.disabled = false


func _on_prueba_sonido_toggled(toggled_on: bool) -> void:
	if toggled_on:
		$sfx_pasos_standing.play()
	else:
		$sfx_pasos_standing.stop()


func _on_sfx_pasos_standing_finished() -> void:
	$sfx_pasos_standing.play()
