extends Node3D

var player: CharacterBody3D
var score: int = 0
@export var total_esferas: int = 2

@export var outro_character: CharacterBody3D
@export var animacao_idle: String = "idle"
@export var animacao_walking: String = "walking"
@export var limite_movimento: float = 0.1

var animation_player: AnimationPlayer
var animacao_atual: String = ""
var camera: Camera3D


# =========================================================
# INICIALIZAÇÃO
# =========================================================
func _ready() -> void:
	_criar_ambiente()
	_criar_plano()
	_criar_cubos_solidos()
	_criar_esferas_coletaveis()
	_configurar_jogador()

	await get_tree().process_frame
	_localizar_animation_player()

	if is_instance_valid(animation_player):
		executar_animacao(animacao_idle)

	print("================================")
	print("JOGO INICIADO | Use WASD/Setas para mover e Espaço para pular.")
	print("================================")


# =========================================================
# MOVIMENTO, ROTAÇÃO E ANIMAÇÃO
# =========================================================
func _physics_process(delta: float) -> void:
	if not is_instance_valid(player):
		return

	# --- Gravidade e Movimento do Jogador ---
	const SPEED: float = 7.0
	const JUMP_VELOCITY: float = 4.5
	var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity", 9.8)

	if not player.is_on_floor():
		player.velocity.y -= gravity * delta

	if Input.is_action_just_pressed("ui_accept") and player.is_on_floor():
		player.velocity.y = JUMP_VELOCITY

	# Pega o input baseado na câmera ou de forma global para não bugar a direção
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction := Vector3(input_dir.x, 0, input_dir.y).normalized()

	if direction:
		player.velocity.x = direction.x * SPEED
		player.velocity.z = direction.z * SPEED
	else:
		player.velocity.x = move_toward(player.velocity.x, 0.0, SPEED)
		player.velocity.z = move_toward(player.velocity.z, 0.0, SPEED)

	player.move_and_slide()

	# --- Rotação baseada apenas na direção do movimento (Sem girar o cenário) ---
	var velocidade_horizontal := Vector2(player.velocity.x, player.velocity.z)
	if velocidade_horizontal.length() > limite_movimento:
		var angulo_alvo := atan2(player.velocity.x, player.velocity.z)
		# Aplica a rotação de forma suave apenas no personagem
		player.rotation.y = lerp_angle(player.rotation.y, angulo_alvo, delta * 15.0)

	# --- Gerenciamento de Animações ---
	var nova_animacao = animacao_walking if velocidade_horizontal.length() > limite_movimento else animacao_idle

	if animacao_atual != nova_animacao:
		executar_animacao(nova_animacao)


# =========================================================
# LOCALIZAÇÃO E ANIMAÇÃO
# =========================================================
func _localizar_animation_player() -> void:
	if not is_instance_valid(player):
		return

	animation_player = _buscar_animation_player(player)
	if not animation_player:
		push_warning("AnimationPlayer não encontrado dentro do personagem.")
		_imprimir_arvore(player)
	else:
		print("AnimationPlayer localizado: ", animation_player.get_path())


func _buscar_animation_player(no: Node) -> AnimationPlayer:
	if no is AnimationPlayer:
		return no
	for filho in no.get_children():
		var encontrado = _buscar_animation_player(filho)
		if encontrado:
			return encontrado
	return null


func executar_animacao(nome_animacao: String) -> void:
	if not is_instance_valid(animation_player) or not animation_player.has_animation(nome_animacao):
		return

	if animation_player.current_animation == nome_animacao and animation_player.is_playing():
		animacao_atual = nome_animacao
		return

	animation_player.play(nome_animacao)
	animacao_atual = nome_animacao


func _imprimir_arvore(no: Node, nivel: int = 0) -> void:
	print("  ".repeat(nivel) + no.name + " [" + no.get_class() + "]")
	for filho in no.get_children():
		_imprimir_arvore(filho, nivel + 1)


# =========================================================
# MECÂNICA DE COLETA
# =========================================================
func _on_esfera_coletada(body: Node3D, esfera: Area3D) -> void:
	if body == player:
		score += 1
		print("Esfera coletada! Total: ", score, "/", total_esferas)
		esfera.queue_free()
		if score >= total_esferas:
			print("Parabéns! Você coletou todas as esferas!")


# =========================================================
# GERAÇÃO DE MUNDO (CENÁRIO)
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


func _criar_cubos_solidos() -> void:
	var posicoes: Array[Vector3] = [
		Vector3(-4, 0.5, -4), Vector3(4, 0.5, -4),
		Vector3(0, 0.5, -6), Vector3(-3, 0.5, 3), Vector3(5, 0.5, 2)
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


func _criar_esferas_coletaveis() -> void:
	var posicoes: Array[Vector3] = [Vector3(-5, 0.5, 5), Vector3(5, 0.5, -2)]
	
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
		area.body_entered.connect(func(body): _on_esfera_coletada(body, area))
		add_child(area)


func _configurar_jogador() -> void:
	if is_instance_valid(outro_character):
		player = outro_character
		
		var tem_colisao := false
		for filho in player.get_children():
			if filho is CollisionShape3D:
				tem_colisao = true
				break
		
		if not tem_colisao:
			var collision_shape := CollisionShape3D.new()
			var capsule_shape := CapsuleShape3D.new()
			capsule_shape.radius = 0.4
			capsule_shape.height = 1.8
			collision_shape.shape = capsule_shape
			collision_shape.position = Vector3(0, 0.9, 0)
			player.add_child(collision_shape)
	else:
		player = CharacterBody3D.new()
		player.name = "Jogador"
		
		var collision_shape := CollisionShape3D.new()
		var capsule_shape := CapsuleShape3D.new()
		collision_shape.shape = capsule_shape
		player.add_child(collision_shape)
		
		add_child(player)

	player.position = Vector3(0, 1, -2)

	# Criação da Câmera fora do Player (ou tratada de forma que não herde rotação indesejada do eixo global)
	# Colocamos a câmera diretamente na raiz (Node3D) para ela ter visão isométrica/estática do cenário,
	# ou acompanhando a posição do player manualmente no _process se preferir que ela siga.
	camera = Camera3D.new()
	camera.name = "CameraCenario"
	camera.position = Vector3(0, 5.5, 8.0)
	camera.rotation_degrees = Vector3(-30, 0, 0)
	add_child(camera)


# Faz a câmera seguir a posição do player suavemente sem girar junto com ele
func _process(delta: float) -> void:
	if is_instance_valid(player) and is_instance_valid(camera):
		var alvo_pos = player.global_position + Vector3(0, 2.5, 6.0)
		camera.global_position = camera.global_position.lerp(alvo_pos, delta * 8.0)
