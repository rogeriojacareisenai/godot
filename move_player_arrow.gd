extends CharacterBody3D

@export var speed: float = 6.0
@export var jump_velocity: float = 4.5
@export var visual_node: Node3D

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

func _physics_process(delta: float) -> void:
	# 1. Gravidade e trava de segurança para não cair
	if global_position.y > 0.0:
		velocity.y -= gravity * delta
	else:
		global_position.y = 0.0
		velocity.y = 0.0

	# 2. Pulo com a barra de Espaço
	if Input.is_key_pressed(KEY_SPACE) and global_position.y <= 0.0:
		velocity.y = jump_velocity

	# 3. Movimentação pelas Setas Direcionais
	var dir := Vector3.ZERO
	if Input.is_action_pressed("ui_left"):  dir.x -= 1.0
	if Input.is_action_pressed("ui_right"): dir.x += 1.0
	if Input.is_action_pressed("ui_up"):    dir.z -= 1.0
	if Input.is_action_pressed("ui_down"):  dir.z += 1.0
	dir = dir.normalized()

	# 4. Aceleração fluida (sem lag)
	velocity.x = move_toward(velocity.x, dir.x * speed, 15.0 * delta)
	velocity.z = move_toward(velocity.z, dir.z * speed, 15.0 * delta)

	# 5. Rotação suave do modelo FBX
	if dir != Vector3.ZERO and visual_node:
		visual_node.rotation.y = lerp_angle(visual_node.rotation.y, atan2(dir.x, dir.z), 15.0 * delta)

	move_and_slide()
