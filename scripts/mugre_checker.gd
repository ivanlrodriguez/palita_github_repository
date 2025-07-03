extends Area2D
class_name mugre_checker

var spawn_mugre := false
var area_limpia := true
var inside_spawn_boundary := false


func _on_body_entered(body: Node2D) -> void:
	if body is StaticBody2D:
		area_limpia = false
	
	elif body is corazon_mundo:
		area_limpia = false
	
	elif body is mugre:
		area_limpia = false
	
	elif area_limpia:
		spawn_mugre = true
