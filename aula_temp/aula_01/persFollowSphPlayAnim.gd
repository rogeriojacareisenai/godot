

extends Node3D

var player: CharacterBody3D
var score: int = 0
var total_esferas: int = 2

@export var outro_character: CharacterBody3D

@export var animacao_idle: String = "idle"
@export var animacao_walking: String = "walking"

# Velocidade mínima para considerar o personagem em movimento.
@export var limite_movimento: float = 0.1

var animation_player: AnimationPlayer
var animacao_atual: String = ""


# =========================================================
# CLASSE DE MOVIMENTO DO JOGADOR
# =========================================================

class PlayerMovel extends CharacterBody3D:
	const SPEED: float = 7.0
	const JUMP_VELOCITY: float = 4.5

	var gravity: float = 9.8
	var camera: Camera3D

	func _ready() -> void:
		gravity = float(
			ProjectSettings.get_setting(
				"physics/3d/default_gravity", 9.8
			)
		)

		camera = Camera3D.new()
		camera.name = "CameraSeguidora"
		camera.position = Vector3(0, 2.5, 4.0)
		camera.rotation_degrees = Vector3(-20, 0, 0)
		add_child(camera)

	func _physics_process(delta: float) -> void:
		if not is_on_floor():
			velocity.y -= gravity * delta

		if Input.is_action_just_pressed("ui_accept") and is_on_floor():
			velocity.y = JUMP_VELOCITY

		var input_dir: Vector2 = Input.get_vector(
			"ui_left",
			"ui_right",
			"ui_up",
			"ui_down"
		)

		var direction: Vector3 = (
			transform.basis
			* Vector3(input_dir.x, 0, input_dir.y)
		).normalized()

		if direction.length() > 0.0:
			velocity.x = direction.x * SPEED
			velocity.z = direction.z * SPEED
		else:
			velocity.x = move_toward(
				velocity.x, 0.0, SPEED
			)
			velocity.z = move_toward(
				velocity.z, 0.0, SPEED
			)

		move_and_slide()


# =========================================================
# INICIALIZAÇÃO
# =========================================================

func _ready() -> void:
	_criar_ambiente()
	_criar_plano()
	_criar_cubos_solidos()
	_criar_esferas_coletaveis()
	_criar_jogador()

	await get_tree().process_frame

	_localizar_animation_player()

	# Começa com a animação de repouso.
	executar_animacao(animacao_idle)

	print("================================")
	print("JOGO INICIADO")
	print("Use WASD ou as setas para mover.")
	print("Use Espaço para pular.")
	print("Parado: idle | Em movimento: walking")
	print("================================")


# =========================================================
# ACOMPANHAMENTO E ANIMAÇÃO AUTOMÁTICA
# =========================================================

func _process(_delta: float) -> void:
	if not is_instance_valid(player):
		return

	# O personagem externo acompanha o jogador.
	if is_instance_valid(outro_character):
		outro_character.global_position = player.global_position

	# Mede somente a velocidade horizontal.
	var velocidade_horizontal := Vector2(
		player.velocity.x,
		player.velocity.z
	).length()

	if velocidade_horizontal > limite_movimento:
		# Jogador em movimento.
		if animacao_atual != animacao_walking:
			executar_animacao(animacao_walking)
	else:
		# Jogador parado.
		if animacao_atual != animacao_idle:
			executar_animacao(animacao_idle)


# =========================================================
# LOCALIZAÇÃO DO ANIMATIONPLAYER
# =========================================================

func _localizar_animation_player() -> void:
	animation_player = null

	if not is_instance_valid(outro_character):
		push_warning(
			"Defina outro_character no Inspector."
		)
		return

	print(
		"Procurando AnimationPlayer em: ",
		outro_character.get_path()
	)

	animation_player = _buscar_animation_player(
		outro_character
	)

	if animation_player == null:
		push_warning("AnimationPlayer não encontrado.")
		print("Estrutura do personagem:")
		_imprimir_arvore(outro_character)
		return

	print(
		"AnimationPlayer localizado: ",
		animation_player.get_path()
	)

	print(
		"Animações disponíveis: ",
		animation_player.get_animation_list()
	)


func _buscar_animation_player(no: Node) -> AnimationPlayer:
	if no is AnimationPlayer:
		return no as AnimationPlayer

	for filho in no.get_children():
		var encontrado := _buscar_animation_player(filho)

		if encontrado != null:
			return encontrado

	return null


# =========================================================
# EXECUÇÃO DAS ANIMAÇÕES
# =========================================================

func executar_animacao(nome_animacao: String) -> void:
	if not is_instance_valid(animation_player):
		_localizar_animation_player()

	if not is_instance_valid(animation_player):
		return

	if not animation_player.is_inside_tree():
		push_warning(
			"AnimationPlayer não está na árvore de cena."
		)
		return

	if not animation_player.has_animation(nome_animacao):
		push_warning(
			"Animação não encontrada: " + nome_animacao
		)
		print(
			"Animações disponíveis: ",
			animation_player.get_animation_list()
		)
		return

	# Não reinicia uma animação que já está sendo executada.
	if (
		animation_player.current_animation == nome_animacao
		and animation_player.is_playing()
	):
		animacao_atual = nome_animacao
		return

	animation_player.play(nome_animacao)
	animacao_atual = nome_animacao

	print("Executando animação: ", nome_animacao)


func _imprimir_arvore(no: Node, nivel: int = 0) -> void:
	print(
		"  ".repeat(nivel),
		no.name,
		" [",
		no.get_class(),
		"]"
	)

	for filho in no.get_children():
		_imprimir_arvore(filho, nivel + 1)


# =========================================================
# COLETA DE ESFERAS
# =========================================================

func _on_esfera_coletada(
	body: Node3D,
	esfera: Area3D
) -> void:
	if body == player:
		score += 1

		print(
			"Esfera coletada! Total: ",
			score,
			"/",
			total_esferas
		)

		esfera.queue_free()

		if score >= total_esferas:
			print(
				"Parabéns! Você coletou todas as esferas!"
			)


# =========================================================
# CRIAÇÃO DO AMBIENTE
# =========================================================

func _criar_ambiente() -> void:
	var light := DirectionalLight3D.new()
	light.rotation_degrees = Vector3(-45, 45, 0)
	light.shadow_enabled = true
	add_child(light)


func _criar_plano() -> void:
	var static_body := StaticBody3D.new()
	var mesh_instance := MeshInstance3D.new()
	var plane_mesh := PlaneMesh.new()

	plane_mesh.size = Vector2(20, 20)
	mesh_instance.mesh = plane_mesh

	var material := StandardMaterial3D.new()
	material.albedo_color = Color(0.3, 0.3, 0.3)
	mesh_instance.material_override = material

	var collision_shape := CollisionShape3D.new()
	var box_shape := BoxShape3D.new()

	box_shape.size = Vector3(20, 0.1, 20)
	collision_shape.shape = box_shape

	static_body.add_child(mesh_instance)
	static_body.add_child(collision_shape)

	add_child(static_body)


# =========================================================
# CUBOS SÓLIDOS
# =========================================================

func _criar_cubos_solidos() -> void:
	var posicoes: Array[Vector3] = [
		Vector3(-4, 0.5, -4),
		Vector3(4, 0.5, -4),
		Vector3(0, 0.5, -6),
		Vector3(-3, 0.5, 3),
		Vector3(5, 0.5, 2)
	]

	var box_mesh := BoxMesh.new()
	var material := StandardMaterial3D.new()

	material.albedo_color = Color(0.8, 0.2, 0.2)
	box_mesh.material = material

	for posicao in posicoes:
		var static_body := StaticBody3D.new()
		var mesh_instance := MeshInstance3D.new()

		mesh_instance.mesh = box_mesh

		var collision_shape := CollisionShape3D.new()
		var box_shape := BoxShape3D.new()

		box_shape.size = Vector3(1, 1, 1)
		collision_shape.shape = box_shape

		static_body.add_child(mesh_instance)
		static_body.add_child(collision_shape)

		static_body.position = posicao
		add_child(static_body)


# =========================================================
# ESFERAS COLETÁVEIS
# =========================================================

func _criar_esferas_coletaveis() -> void:
	var posicoes: Array[Vector3] = [
		Vector3(-5, 0.5, 5),
		Vector3(5, 0.5, -2)
	]

	var sphere_mesh := SphereMesh.new()
	sphere_mesh.radius = 0.4
	sphere_mesh.height = 0.8

	var material := StandardMaterial3D.new()
	material.albedo_color = Color(1, 0.84, 0)

	sphere_mesh.material = material

	for posicao in posicoes:
		var area := Area3D.new()
		var mesh_instance := MeshInstance3D.new()

		mesh_instance.mesh = sphere_mesh

		var collision_shape := CollisionShape3D.new()
		var sphere_shape := SphereShape3D.new()

		sphere_shape.radius = 0.4
		collision_shape.shape = sphere_shape

		area.add_child(mesh_instance)
		area.add_child(collision_shape)

		area.position = posicao

		area.body_entered.connect(
			func(body: Node3D) -> void:
				_on_esfera_coletada(body, area)
		)

		add_child(area)


# =========================================================
# CRIAÇÃO DO JOGADOR
# =========================================================

func _criar_jogador() -> void:
	player = PlayerMovel.new()
	player.name = "Jogador"
	player.position = Vector3(0, 1, 6)

	var mesh_instance := MeshInstance3D.new()
	var sphere_mesh := SphereMesh.new()

	sphere_mesh.radius = 0.5
	sphere_mesh.height = 1.0

	mesh_instance.mesh = sphere_mesh

	var material := StandardMaterial3D.new()
	material.albedo_color = Color(0.1, 0.5, 0.9)

	mesh_instance.material_override = material

	var collision_shape := CollisionShape3D.new()
	var sphere_shape := SphereShape3D.new()

	sphere_shape.radius = 0.5
	collision_shape.shape = sphere_shape

	player.add_child(mesh_instance)
	player.add_child(collision_shape)

	add_child(player)
