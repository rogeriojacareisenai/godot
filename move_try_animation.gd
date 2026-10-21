extends CharacterBody3D

@export var speed: float = 6.0
@export var jump_velocity: float = 4.5
@export var visual_node: Node3D

# Referência ao AnimationPlayer
@export var anim_player: AnimationPlayer

# Variáveis para luz e interface de texto na tela
var sun_light: DirectionalLight3D
var status_label: Label

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready() -> void:
	setup_sun_light()
	setup_ui_message() # Cria o texto na tela de forma otimizada
	
	# Procura o AnimationPlayer automaticamente caso não esteja atribuído no Inspetor
	if not anim_player and visual_node:
		anim_player = find_animation_player(visual_node)
		
	if anim_player:
		mostrar_mensagem("AnimationPlayer encontrado com sucesso!")
		if anim_player.has_animation("mixamo_com"):
			var anim = anim_player.get_animation("mixamo_com")
			anim.loop_mode = Animation.LOOP_LINEAR
		elif anim_player.has_animation("Take 001"):
			var anim = anim_player.get_animation("Take 001")
			anim.loop_mode = Animation.LOOP_LINEAR
	else:
		mostrar_mensagem("ERRO: AnimationPlayer não encontrado!")

# Função para criar o texto flutuante (Label) na tela
func setup_ui_message() -> void:
	var canvas_layer = CanvasLayer.new()
	add_child(canvas_layer)
	
	status_label = Label.new()
	status_label.text = "Jogo Iniciado - Pronto!"
	status_label.position = Vector2(20, 20)
	status_label.add_theme_font_size_override("font_size", 20)
	status_label.add_theme_color_override("font_color", Color.WHITE)
	canvas_layer.add_child(status_label)

func mostrar_mensagem(texto: String) -> void:
	if status_label:
		status_label.text = texto
	print(texto)

# Função auxiliar para encontrar o AnimationPlayer na árvore de nós
func find_animation_player(node: Node) -> AnimationPlayer:
	if node is AnimationPlayer:
		return node as AnimationPlayer
	for child in node.get_children():
		var found = find_animation_player(child)
		if found:
			return found
	return null

func setup_sun_light() -> void:
	sun_light = DirectionalLight3D.new()
	sun_light.name = "SunLight"
	sun_light.light_color = Color(1.0, 0.98, 0.9)
	sun_light.light_energy = 1.2
	sun_light.shadow_enabled = true
	sun_light.rotation_degrees = Vector3(-45.0, -30.0, 0.0)
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
		mostrar_mensagem("Ação: Pulando!") # Mensagem chamada apenas no evento de pulo (sem lag)

	# 3. Movimentação pelas Setas Direcionais
	var dir := Vector3.ZERO
	if Input.is_action_pressed("ui_left"):  dir.x -= 1.0
	if Input.is_action_pressed("ui_right"): dir.x += 1.0
	if Input.is_action_pressed("ui_up"):    dir.z -= 1.0
	if Input.is_action_pressed("ui_down"):  dir.z += 1.0
	dir = dir.normalized()

	# 4. Aceleração fluida
	velocity.x = move_toward(velocity.x, dir.x * speed, 15.0 * delta)
	velocity.z = move_toward(velocity.z, dir.z * speed, 15.0 * delta)

	# 5. Rotação suave do modelo FBX
	if dir != Vector3.ZERO and visual_node:
		visual_node.rotation.y = lerp_angle(visual_node.rotation.y, atan2(dir.x, dir.z), 15.0 * delta)

	move_and_slide()

	# 6. Controle de Animação
	update_animation(dir)

func update_animation(dir: Vector3) -> void:
	if not anim_player:
		return

	var target_anim: String = ""

	if dir != Vector3.ZERO:
		if anim_player.has_animation("mixamo_com"):
			target_anim = "mixamo_com"
		elif anim_player.has_animation("Take 001"):
			target_anim = "Take 001"
	else:
		if anim_player.has_animation("Take 001"):
			target_anim = "Take 001"
		elif anim_player.has_animation("Idle"):
			target_anim = "Idle"

	if target_anim != "" and anim_player.current_animation != target_anim:
		anim_player.play(target_anim)
	elif target_anim == "" and dir == Vector3.ZERO and anim_player.is_playing():
		anim_player.stop()
