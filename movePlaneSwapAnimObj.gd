
extends Node3D

@onready var c1: CharacterBody3D = $CharacterBody3D    # Idle
@onready var c2: CharacterBody3D = $CharacterBody3D2  # Walking
@onready var camera: Camera3D = $Camera3D              # Câmara Principal

var ap1: AnimationPlayer
var ap2: AnimationPlayer
var estado_andando: bool = false

@export var velocidade: float = 3.0
@export var velocidade_giro: float = 3.0

func _ready() -> void:
	ap1 = c1.find_child("AnimationPlayer", true, false)
	ap2 = c2.find_child("AnimationPlayer", true, false)
	
	criar_cenario_basico()
	criar_objetos() # <--- Adiciona o cubo e a esfera no cenário
	normalizar_modelos()
	mudar_estado(false)
	
	if camera and c1:
		var offset: Vector3 = -c1.transform.basis.z * 3.0 + Vector3(0, 1.5, 0)
		camera.global_position = c1.global_position + offset
		camera.look_at(c1.global_position + Vector3(0, 1.0, 0), Vector3.UP)

func criar_cenario_basico() -> void:
	var corpo_chao := StaticBody3D.new()
	
	var colisao := CollisionShape3D.new()
	var formato_chao := BoxShape3D.new()
	formato_chao.size = Vector3(60.0, 1.0, 60.0)
	colisao.shape = formato_chao
	colisao.position.y = -0.5
	corpo_chao.add_child(colisao)
	
	var mesh_instance := MeshInstance3D.new()
	var box_mesh := BoxMesh.new()
	box_mesh.size = Vector3(60.0, 1.0, 60.0)
	mesh_instance.mesh = box_mesh
	mesh_instance.position.y = -0.5
	corpo_chao.add_child(mesh_instance)
	
	add_child(corpo_chao)
	
	var luz := DirectionalLight3D.new()
	luz.rotation_degrees = Vector3(-45, 45, 0)
	luz.shadow_enabled = true
	add_child(luz)

# Função para criar o cubo e a esfera com colisão no plano
func criar_objetos() -> void:
	# --- 1. CRIAR O CUBO ---
	var cubo := StaticBody3D.new()
	cubo.position = Vector3(3.0, 0.5, -3.0) # Posição ao lado do personagem
	
	var col_cubo := CollisionShape3D.new()
	var shape_cubo := BoxShape3D.new()
	col_cubo.shape = shape_cubo
	cubo.add_child(col_cubo)
	
	var mesh_cubo := MeshInstance3D.new()
	mesh_cubo.mesh = BoxMesh.new()
	cubo.add_child(mesh_cubo)
	
	add_child(cubo)

	# --- 2. CRIAR A ESFERA ---
	var esfera := StaticBody3D.new()
	esfera.position = Vector3(-3.0, 0.5, -3.0) # Posição do outro lado
	
	var col_esfera := CollisionShape3D.new()
	var shape_esfera := SphereShape3D.new()
	col_esfera.shape = shape_esfera
	esfera.add_child(col_esfera)
	
	var mesh_esfera := MeshInstance3D.new()
	mesh_esfera.mesh = SphereMesh.new()
	esfera.add_child(mesh_esfera)
	
	add_child(esfera)

func normalizar_modelos() -> void:
	c1.scale = Vector3.ONE
	c2.scale = Vector3.ONE
	
	var m1 = c1.get_child(0) as Node3D
	var m2 = c2.get_child(0) as Node3D
	if m1: m1.position = Vector3.ZERO
	if m2: m2.position = Vector3.ZERO

func _physics_process(delta: float) -> void:
	var giro: float = Input.get_axis("ui_right", "ui_left")
	var avanco: float = Input.get_axis("ui_up", "ui_down")

	var quer_mover: bool = (avanco != 0.0 or giro != 0.0)

	if quer_mover != estado_andando:
		estado_andando = quer_mover
		mudar_estado(estado_andando)

	var ativo: CharacterBody3D = c2 if estado_andando else c1
	var inativo: CharacterBody3D = c1 if estado_andando else c2

	if ativo:
		ativo.rotate_y(giro * velocidade_giro * delta)
		
		var direcao: Vector3 = -ativo.transform.basis.z * avanco
		ativo.velocity = direcao * velocidade
		ativo.move_and_slide()
		
		if inativo:
			inativo.global_transform = ativo.global_transform
		
		if camera:
			var offset: Vector3 = -ativo.transform.basis.z * 3.0 + Vector3(0, 1.5, 0)
			var posicao_alvo: Vector3 = ativo.global_position + offset
			camera.global_position = camera.global_position.lerp(posicao_alvo, delta * 6.0)
			camera.look_at(ativo.global_position + Vector3(0, 1.0, 0), Vector3.UP)

func mudar_estado(andando: bool) -> void:
	c1.visible = !andando
	c2.visible = andando
	
	if ap1: ap1.stop()
	if ap2: ap2.stop()
	
	var ap_ativo: AnimationPlayer = ap2 if andando else ap1
	
	if ap_ativo:
		var lista_anims = ap_ativo.get_animation_list()
		if lista_anims.size() > 0:
			var nome_anim = lista_anims[0]
			var anim = ap_ativo.get_animation(nome_anim)
			if anim:
				anim.loop_mode = Animation.LOOP_LINEAR
			
			ap_ativo.play(nome_anim)
