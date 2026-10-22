extends CharacterBody3D

@onready var ap: AnimationPlayer = find_child("AnimationPlayer", true, false)

# Constantes de movimentação e física
const SPEED: float = 5.0
const JUMP_VELOCITY: float = 4.5
const ROTATION_SPEED: float = 15.0 

func _ready() -> void:
	# 1. Cria a luz do ambiente
	criar_luz()
	
	# Posiciona o personagem para testar a queda de forma segura
	global_position = Vector3(0, 2.0, 0)
	
	# 2. Configura o AnimationPlayer e o loop das animações
	if ap:
		ap.active = true
		
		if ap.has_animation("walking"):
			ap.get_animation("walking").loop_mode = Animation.LOOP_LINEAR
		if ap.has_animation("idle"):
			ap.get_animation("idle").loop_mode = Animation.LOOP_LINEAR
			
		tocar_animacao("idle")
		mostrar_mensagem("Sucesso: Ambiente e CharacterBody3D prontos!", Color.GREEN)
	else:
		mostrar_mensagem("ERRO: AnimationPlayer não encontrado na cena!", Color.RED)

func _physics_process(delta: float) -> void:

	# 2. Tratamento de entrada (Input) para movimento
	var input_dir := Vector3.ZERO
	if Input.is_action_pressed("ui_right"):
		input_dir.x += 1
	if Input.is_action_pressed("ui_left"):
		input_dir.x -= 1
	if Input.is_action_pressed("ui_down"):
		input_dir.z += 1
	if Input.is_action_pressed("ui_up"):
		input_dir.z -= 1
	
	input_dir = input_dir.normalized()

	# 3. Gerencia a velocidade no plano XZ e rotação
	if input_dir != Vector3.ZERO:
		velocity.x = input_dir.x * SPEED
		velocity.z = input_dir.z * SPEED
		
		var target_rotation = atan2(input_dir.x, input_dir.z)
		rotation.y = lerp_angle(rotation.y, target_rotation, ROTATION_SPEED * delta)
		
		tocar_animacao("walking")
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		
		tocar_animacao("idle")

	# 4. Executa a movimentação e física de colisão
	move_and_slide()

	# Segurança para reposicionar caso o personagem caia fora do mapa
	if global_position.y < -10:
		global_position = Vector3(0, 3.0, 0)
		velocity = Vector3.ZERO

func tocar_animacao(nome_animacao: String) -> void:
	if ap and ap.has_animation(nome_animacao):
		ap.active = true
		
		if ap.current_animation != nome_animacao:
			ap.play(nome_animacao, false)
			
			if nome_animacao == "walking":
				ap.seek(0, true)

func criar_luz() -> void:
	var luz = DirectionalLight3D.new()
	luz.name = "LuzSolar"
	luz.light_energy = 1.5
	luz.shadow_enabled = true
	luz.rotation_degrees = Vector3(-45, 45, 0)
	luz.position = Vector3(0, 15, 0)
	add_child(luz)

func mostrar_mensagem(texto: String, cor: Color) -> void:
	var camada = CanvasLayer.new()
	var rotulo = Label.new()
	rotulo.text = texto
	rotulo.position = Vector2(20, 20)
	rotulo.add_theme_color_override("font_color", cor)
	camada.add_child(rotulo)
	add_child(camada)
