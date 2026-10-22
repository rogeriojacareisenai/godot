extends Node3D

var player: CharacterBody3D
var score: int = 0
var total_esferas: int = 2

# 1. Classe interna de movimento e câmera do jogador
class PlayerMovel extends CharacterBody3D:
	const SPEED = 7.0
	const JUMP_VELOCITY = 4.5
	var gravity = 9.8
	var camera: Camera3D

	func _ready() -> void:
		if ProjectSettings.has_setting("physics/3d/default_gravity"):
			gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
			
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

		var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
		var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		
		if direction:
			velocity.x = direction.x * SPEED
			velocity.z = direction.z * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			velocity.z = move_toward(velocity.z, 0, SPEED)

		move_and_slide()

# 2. Callback de coleta posicionado no topo para evitar erros de escopo
func _on_esfera_coletada(body: Node3D, esfera: Area3D) -> void:
	if body == player:
		score += 1
		print("Esfera coletada! Total: ", score, "/", total_esferas)
		esfera.queue_free()
		if score >= total_esferas:
			print("Parabéns! Você coletou todas as esferas!")

# 3. Execução principal
func _ready() -> void:
	_criar_ambiente()
	_criar_plano()
	_criar_cubos_solidos()
	_criar_esferas_coletaveis()
	_criar_jogador()
	
	print("--- Jogo Iniciado! Use W, A, S, D para mover e Espaço para pular ---")

func _criar_ambiente() -> void:
	var light = DirectionalLight3D.new()
	light.rotation_degrees = Vector3(-45, 45, 0)
	light.shadow_enabled = true
	add_child(light)

func _criar_plano() -> void:
	var static_body = StaticBody3D.new()
	var mesh_instance = MeshInstance3D.new()
	var plane_mesh = PlaneMesh.new()
	plane_mesh.size = Vector2(20, 20)
	mesh_instance.mesh = plane_mesh
	
	var material = StandardMaterial3D.new()
	material.albedo_color = Color(0.3, 0.3, 0.3)
	mesh_instance.material_override = material
	
	var collision_shape = CollisionShape3D.new()
	var box_shape = BoxShape3D.new()
	box_shape.size = Vector3(20, 0.1, 20)
	collision_shape.shape = box_shape
	
	static_body.add_child(mesh_instance)
	static_body.add_child(collision_shape)
	add_child(static_body)

func _criar_cubos_solidos() -> void:
	var posicoes = [
		Vector3(-4, 0.5, -4),
		Vector3(4, 0.5, -4),
		Vector3(0, 0.5, -6),
		Vector3(-3, 0.5, 3),
		Vector3(5, 0.5, 2)
	]
	
	var box_mesh = BoxMesh.new()
	var material = StandardMaterial3D.new()
	material.albedo_color = Color(0.8, 0.2, 0.2)
	box_mesh.material = material

	for i in range(posicoes.size()):
		var static_body = StaticBody3D.new()
		var mesh_instance = MeshInstance3D.new()
		mesh_instance.mesh = box_mesh
		
		var collision_shape = CollisionShape3D.new()
		var box_shape = BoxShape3D.new()
		box_shape.size = Vector3(1, 1, 1)
		collision_shape.shape = box_shape
		
		static_body.add_child(mesh_instance)
		static_body.add_child(collision_shape)
		static_body.position = posicoes[i]
		add_child(static_body)

func _criar_esferas_coletaveis() -> void:
	var posicoes = [
		Vector3(-5, 0.5, 5),
		Vector3(5, 0.5, -2)
	]
	
	var sphere_mesh = SphereMesh.new()
	sphere_mesh.radius = 0.4
	sphere_mesh.height = 0.8
	var material = StandardMaterial3D.new()
	material.albedo_color = Color(1, 0.84, 0)
	sphere_mesh.material = material

	for i in range(posicoes.size()):
		var area = Area3D.new()
		var mesh_instance = MeshInstance3D.new()
		mesh_instance.mesh = sphere_mesh
		
		var collision_shape = CollisionShape3D.new()
		var sphere_shape = SphereShape3D.new()
		sphere_shape.radius = 0.4
		collision_shape.shape = sphere_shape
		
		area.add_child(mesh_instance)
		area.add_child(collision_shape)
		area.position = posicoes[i]
		
		area.body_entered.connect(func(body): _on_esfera_coletada(body, area))
		add_child(area)

func _criar_jogador() -> void:
	player = PlayerMovel.new()
	player.name = "Jogador"
	player.position = Vector3(0, 1, 6)
	
	var mesh_instance = MeshInstance3D.new()
	var sphere_mesh = SphereMesh.new()
	sphere_mesh.radius = 0.5
	sphere_mesh.height = 1.0
	mesh_instance.mesh = sphere_mesh
	
	var material = StandardMaterial3D.new()
	material.albedo_color = Color(0.1, 0.5, 0.9)
	mesh_instance.material_override = material
	
	var collision_shape = CollisionShape3D.new()
	var sphere_shape = SphereShape3D.new()
	sphere_shape.radius = 0.5
	collision_shape.shape = sphere_shape
	
	player.add_child(mesh_instance)
	player.add_child(collision_shape)
	add_child(player)
