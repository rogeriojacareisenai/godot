extends CharacterBody3D

# Configurações de Física e Movimento
@export var SPEED: float = 10.0      

# Altura máxima do pulo em metros/unidades
@export var JUMP_HEIGHT: float = 34.0  

# Multiplicadores de Gravidade (Valores altos podem causar instabilidade se colidir com paredes, ajustados para estabilidade)
@export var JUMP_GRAVITY_MULTIPLIER: float = 15.0  
@export var FALL_GRAVITY_MULTIPLIER: float = 25.0 

# Referência ao nó de animações
@onready var animation_player: AnimationPlayer = $AuxScene/AnimationPlayer
@onready var aux_scene: Node3D = $AuxScene

func _physics_process(delta: float) -> void:
	# 1. Aplica a gravidade personalizada quando não estiver no chão
	if not is_on_floor():
		var gravity = get_gravity() * delta
		
		if velocity.y > 0:
			velocity += gravity * JUMP_GRAVITY_MULTIPLIER
		else:
			velocity += gravity * FALL_GRAVITY_MULTIPLIER

	# 2. Lógica do Pulo
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = sqrt(2.0 * JUMP_HEIGHT * abs(get_gravity().y) * JUMP_GRAVITY_MULTIPLIER)

	# 3. Obtém o vetor de entrada dos controles direcionais
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	# 4. Movimentação e Rotação do Modelo (Suavizada com delta para evitar trancos)
	if direction != Vector3.ZERO:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
		
		var target_rotation = atan2(-direction.x, -direction.z)
		aux_scene.rotation.y = lerp_angle(aux_scene.rotation.y, target_rotation, 15.0 * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	# 5. Executa o movimento com colisões
	move_and_slide()

	# 6. Atualização de Animações
	_update_animations(input_dir)

func _update_animations(input_dir: Vector2) -> void:
	if animation_player == null:
		return

	if input_dir != Vector2.ZERO and is_on_floor():
		if animation_player.current_animation != "walking":
			animation_player.play("walking")
		animation_player.speed_scale = SPEED / 5.0 
	elif is_on_floor():
		if animation_player.current_animation != "idle":
			animation_player.play("idle")
		animation_player.speed_scale = 1.0
