extends CharacterBody3D

@export var speed: float = 6.0
@export var jump_velocity: float = 4.5
@export var visual_node: Node3D

# Variável para armazenar a luz do sol
var sun_light: DirectionalLight3D

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready() -> void:
	# Cria e configura a iluminação solar para todo o cenário
	setup_sun_light()

func setup_sun_light() -> void:
	sun_light = DirectionalLight3D.new()
	sun_light.name = "SunLight"
	
	# Configurações de cor e energia para simular o sol
	sun_light.light_color = Color(1.0, 0.98, 0.9) # Cor solar levemente amarelada
	sun_light.light_energy = 1.2                 # Intensidade da luz do sol
	sun_light.shadow_enabled = true              # Ativa sombras projetadas no cenário
	
	# Ajusta a inclinação/orientação do sol (Ângulo de incidência dos raios solares)
	# x: -45 graus (inclinação para baixo), y: -30 graus (direção do sol no horizonte)
	sun_light.rotation_degrees = Vector3(-45.0, -30.0, 0.0)
	
	# Adiciona a luz do sol na raiz da cena atual para iluminar todo o ambiente
	get_tree().current_scene.add_child.call_deferred(sun_light)

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
