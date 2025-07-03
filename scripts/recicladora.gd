extends StaticBody2D

signal reciclar_signal(mugre_ref)

@onready var cuerpo := $cuerpo_anim
@onready var cinta := $cinta_anim
var current_frame :=0

func _ready() -> void:
	var mundo = get_parent()
	connect("reciclar_signal", Callable(mundo, "_on_reciclar"))
	cinta.stop()
	cuerpo.play("carga")
	cuerpo.stop()

func _on_hueco_body_entered(body: Node2D) -> void:
	if body is mugre:
		body.set_rigid_mode()
		body.gravity_scale = 1


func _on_hueco_body_exited(body: Node2D) -> void:
	if body is mugre:
		emit_signal("reciclar_signal", body)


func _on_cinta_body_entered(body: Node2D) -> void:
	if body is RigidBody2D:
		body.add_to_group('in_cinta')


func _on_cinta_body_exited(body: Node2D) -> void:
	if body is RigidBody2D:
		body.remove_from_group('in_cinta')

func _physics_process(_delta: float) -> void:
	var bodies_in_cinta = get_tree().get_nodes_in_group('in_cinta')
	for body in bodies_in_cinta:
		body.apply_impulse(Vector2.from_angle(PI/6) * 2)


#funcion para avanzar la barra de carga con una señal externa
#func _on_controller_advance_frame():
	#step_frame()
	
func step_frame():
	current_frame += 1
	var frame_count = cuerpo.sprite_frames.get_frame_count("carga")
	print(frame_count)
	
#	animacion para correr toda la seguidilla de produccion y reseteo
	if current_frame == frame_count:
		cuerpo.play("full", 6.0)
		await get_tree().create_timer(6.0).timeout
		cuerpo.play("flechas",6.0)
		cinta.play("default", 6.0)
		await get_tree().create_timer(6.0).timeout
		cinta.stop()
		cuerpo.play("carga")
		cuerpo.stop()
		current_frame = 0
	current_frame %= frame_count
	cuerpo.frame = current_frame
