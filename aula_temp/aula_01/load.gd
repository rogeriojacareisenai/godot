extends Node3D

@onready var ap: AnimationPlayer = find_child("AnimationPlayer", true, false)

func _ready() -> void:
	# 1. Cria o ambiente (Chão grande de 60x60 com colisão e iluminação)
	criar_ambiente()
	
	# 2. Configura o AnimationPlayer e o loop das animações
	if ap:
		ap.active = true
		
		if ap.has_animation("walk"):
			ap.get_animation("walk").loop_mode = Animation.LOOP_LINEAR
		if ap.has_animation("idle"):
			ap.get_animation("idle").loop_mode = Animation.LOOP_LINEAR
			
		# Inicia o jogo já no estado de descanso (idle)
		tocar_animacao("idle")
		mostrar_mensagem("Sucesso: Ambiente e AnimationPlayer prontos!", Color.GREEN)
	else:
		mostrar_mensagem("ERRO: AnimationPlayer não encontrado na cena!", Color.RED)

func _process(delta: float) -> void:
	if not ap:
		return
	
	var movendo: bool = false
	var direcao := Vector3.ZERO

	# Identificação individual de cada tecla de seta (Input map padrão)
	if Input.is_action_pressed("ui_right"):
		direcao.x += 1
		movendo = true
		
	if Input.is_action_pressed("ui_left"):
		direcao.x -= 1
		movendo = true
		
	if Input.is_action_pressed("ui_down"):
		direcao.z += 1
		movendo = true
		
	if Input.is_action_pressed("ui_up"):
		direcao.z -= 1
		movendo = true

	# Gerencia o movimento, a rotação e as animações
	if movendo:
		# Rotaciona o personagem instantaneamente para a direção da tecla pressionada
		var angulo = atan2(direcao.x, direcao.z)
		rotation.y = angulo
		
		# Ativa a animação de andar sem delay
		tocar_animacao("walk")
	else:
		# Se nenhuma seta estiver pressionada, ativa o idle
		tocar_animacao("idle")

# Função segura para troca rápida de animação sem atrasos
func tocar_animacao(nome_animacao: String) -> void:
	if ap and ap.has_animation(nome_animacao):
		ap.active = true
		
		if ap.current_animation != nome_animacao:
			# custom_blend = 0.0 corta qualquer atraso de transição
			ap.play(nome_animacao,  false)
			
			# Remove o delay interno inicial da animação 'walk' pulando direto para o frame útil
			if nome_animacao == "walk":
				ap.seek(2.15, true) # Ajuste este valor (ex: 0.1 ou 0.2) se precisar refinar o corte

func criar_ambiente() -> void:
	# --- Criação do Chão (60x60 com Colisão) ---
	var static_body = StaticBody3D.new()
	static_body.name = "ChaoGrande"
	
	var mesh_instance = MeshInstance3D.new()
	var plane_mesh = PlaneMesh.new()
	plane_mesh.size = Vector2(60, 60)
	mesh_instance.mesh = plane_mesh
	
	var collision_shape = CollisionShape3D.new()
	var box_shape = BoxShape3D.new()
	box_shape.size = Vector3(60, 0.1, 60)
	collision_shape.shape = box_shape
	
	static_body.add_child(mesh_instance)
	static_body.add_child(collision_shape)
	add_child(static_body)
	
	# --- Criação da Luz Direcional (Sol) ---
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
