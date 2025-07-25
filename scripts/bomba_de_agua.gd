extends RigidBody2D
class_name bomba

signal stop_player_movement_signal()
signal restore_player_movement_signal()
signal spawn_agua_signal(bomba_ref)
signal toss_triggered_signal(jugador_ref)

# Movement
var tossed := false
var arrancada := true
var planting := false

var dragging := false
var drag_strength: float
const UP_DRAG_STRENGTH := 8.0 
const DOWN_DRAG_STRENGTH := 2.0 # lower means harder
var mouse_pos: Vector2
var to_mouse: Vector2
var rotation_target := 0.0

var spawn_area: Vector2
var agua_spawn_cooldown := 0.05 # seconds between spawns
var agua_spawn_timer := 0.0


func set_collision_layer_bit(layer: int, enabled: bool) -> void:
	if enabled:
		collision_layer |= 1 << (layer - 1)  # Turn ON bit
	else:
		collision_layer &= ~(1 << (layer - 1))  # Turn OFF bit


func set_collision_mask_bit(layer: int, enabled: bool) -> void:
	if enabled:
		collision_mask |= 1 << (layer - 1)
	else:
		collision_mask &= ~(1 << (layer - 1))



func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_released('click_izq'):
		dragging = false
		emit_signal("restore_player_movement_signal")


func _ready():
	set_deferred("freeze", false)
	arrancada = true
	var player = get_parent().get_node("jugador")
	connect("stop_player_movement_signal", Callable(player, "_on_stop_player_movement"))
	connect("restore_player_movement_signal", Callable(player, "_on_restore_player_movement"))
	connect("toss_triggered_signal", Callable(player, "_on_toss_triggered"))
	var mundo = get_parent()
	connect("spawn_agua_signal", Callable(mundo, "_on_spawn_agua"))
	# anim salida
	z_index = 2
	set_physics_process(false)
	set_collision_layer_bit(2, false)
	set_collision_mask_bit(1, false)
	rotation = -PI/3
	await get_tree().create_timer(6.3).timeout
	z_index = 3
	set_physics_process(true)
	set_collision_layer_bit(2, true)
	set_collision_mask_bit(1, true)
	var tween := create_tween()
	tween.tween_property(self, "rotation", 0.0, 1.0) \
		 .set_trans(Tween.TRANS_SINE) \
		 .set_ease(Tween.EASE_OUT)


func _on_manija_input_event(_viewport: Viewport, event: InputEvent, _shape_idx: int) -> void:
	if event.is_action_pressed('click_izq'):
		dragging = true
		set_process(true)
		emit_signal("stop_player_movement_signal")


func on_toss_triggered(_player_ref: Node):
	if not $tossable_component.in_toss_area:
		return
	arrancada = true
	set_collision_layer_bit(1, false)
	set_collision_layer_bit(5, false)
	set_collision_mask_bit(2, true)
	set_physics_process(true)

func _process(delta):
	if dragging:
		mouse_pos = get_global_mouse_position()
		to_mouse = mouse_pos - $brazo.global_position
		rotation_target = to_mouse.angle() - PI/2
		if to_mouse.y < 0:
			drag_strength = UP_DRAG_STRENGTH
		else:
			drag_strength = DOWN_DRAG_STRENGTH
		var lerp_brazo_rotation = lerp_angle($brazo.rotation, rotation_target, delta * DOWN_DRAG_STRENGTH)
		var clamped_lerp_brazo_rotation = clamp(lerp_brazo_rotation, 0, PI/2)
		$brazo.rotation = clamped_lerp_brazo_rotation
		
		var diferencial_manija = abs(rotation_target) - abs(lerp_brazo_rotation)
		# Update timer
		agua_spawn_timer -= delta
		if diferencial_manija < -0.2 and agua_spawn_timer <= 0:
			agua_spawn_timer = agua_spawn_cooldown
			emit_signal("spawn_agua_signal", self)
	else:
		rotation_target = 0.0
		$brazo.rotation = lerp_angle($brazo.rotation, rotation_target, delta * DOWN_DRAG_STRENGTH)
		agua_spawn_timer -= delta/10
		if agua_spawn_timer <= 0:
			agua_spawn_timer = agua_spawn_cooldown
			emit_signal("spawn_agua_signal", self)
		if $brazo.rotation <= 0.01:
			set_process(false)
	
	var start_point = Vector2(0, -11.0) # Fixed anchor point in ChainLine's local space
	var brazo_tip_local = Vector2(4.0, -11.0) # Right edge
	var brazo_tip_global = $brazo.to_global(brazo_tip_local)
	var tip_in_chain_space = $cadena.to_local(brazo_tip_global)
	
	$cadena.points = [start_point, tip_in_chain_space]



func _physics_process(_delta: float) -> void:
	rotation = clamp(rotation, -PI/2, PI)
	if linear_velocity.length() < 0.1:
		linear_velocity = Vector2.ZERO
	if linear_velocity == Vector2.ZERO and not planting:
		planting = true
		$tiempo_plantacion.start()
	elif linear_velocity != Vector2.ZERO:
		set_collision_layer_bit(1, false)
		set_collision_layer_bit(5, false)
		set_collision_mask_bit(2, true)
		planting = false
		$tiempo_plantacion.stop()

func _on_tiempo_plantacion_timeout() -> void:
	planting = false
	arrancada = false
	set_collision_layer_bit(1, true)
	set_collision_layer_bit(5, true)
	set_collision_mask_bit(2, false)
	set_physics_process(false)
	set_deferred('freeze_mode', 0)
	set_deferred("freeze", true)
	var tween := create_tween()
	tween.tween_property(self, "rotation", 0.0, 1.0) \
		 .set_trans(Tween.TRANS_SINE) \
		 .set_ease(Tween.EASE_OUT)
	await get_tree().create_timer(1.0).timeout
	spawn_area = $spawn_area/spawn_area_collsh.global_position
