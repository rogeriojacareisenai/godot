# configuração:
#Node3D
# Camera3D
# Character3D (script deve estar associado a este componente)
#->Running (FBX)

  
extends CharacterBody3D

@export var speed: float = 5.0
@export var jump_velocity: float = 4.5
@export var visual_node: Node3D

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

func _physics_process(delta: float) -> void:
	# 1. Gravidade e Limite de Segurança para não cair abaixo de Y = 0
	if global_position.y > 0.0:
		velocity.y -= gravity * delta
	else:
		global_position.y = 0.0
		velocity.y = 0.0

	# 2. Pulo
	if Input.is_action_just_pressed("ui_accept") and global_position.y <= 0.0:
		velocity.y = jump_velocity

	# 3. Movimento direcional (WASD / Setas)
	var dir := Vector3(Input.get_axis("ui_left", "ui_right"), 0, Input.get_axis("ui_up", "ui_down")).normalized()
	
	velocity.x = move_toward(velocity.x, dir.x * speed, 12.0 * delta)
	velocity.z = move_toward(velocity.z, dir.z * speed, 12.0 * delta)

	# 4. Rotação suave do FBX
	if dir and visual_node:
		visual_node.rotation.y = lerp_angle(visual_node.rotation.y, atan2(dir.x, dir.z), 12.0 * delta)

	move_and_slide()
