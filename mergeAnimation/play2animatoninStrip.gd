
extends Node3D

# Referência para o AnimationPlayer dentro da sua estrutura
@onready var animation_player: AnimationPlayer = $CharacterBody3D/AuxScene/AnimationPlayer

# Escala ajustada para o personagem (pode alterar no Inspetor do Godot se necessário)
@export var escala_desejada: Vector3 = Vector3(10, 10, 10)

func _ready() -> void:
	# 1. Cria iluminação e cores para evitar cinzentos chapados
	criar_iluminacao()
	aplicar_material_visivel()
	
	# 2. Inicia a primeira animação de forma segura
	if animation_player:
		await get_tree().process_frame
		tocar_animacao("a1")
	else:
		print("Erro crítico: AnimationPlayer não foi encontrado no caminho especificado!")

func _input(event: InputEvent) -> void:
	# Pressione a tecla '1' para a1, ou '2' para a2
	if Input.is_key_pressed(KEY_1):
		tocar_animacao("a1")
	elif Input.is_key_pressed(KEY_2):
		tocar_animacao("a2")

func tocar_animacao(nome_anim: String) -> void:
	if animation_player and animation_player.has_animation(nome_anim):
		animation_player.play(nome_anim)
		
		# Força todos os nós a ficarem visíveis e na escala correcta
		var aux_scene = $CharacterBody3D/AuxScene
		for child in aux_scene.find_children("*", "", true, false):
			if child is Node3D:
				child.visible = true
				child.scale = escala_desejada
					
		print("A reproduzir animação: ", nome_anim)
	else:
		print("Animação não encontrada ou AnimationPlayer nulo: ", nome_anim)

# Mantém a escala travada no tamanho correto caso alguma chave antiga tente alterá-la
func _process(_delta: float) -> void:
	var aux_scene = $CharacterBody3D/AuxScene
	if aux_scene:
		for child in aux_scene.find_children("*", "", true, false):
			if child is Node3D and (child.scale.x < 0.1 or child.scale.x != escala_desejada.x):
				child.scale = escala_desejada

# Cria luzes dinâmicas na cena via código
func criar_iluminacao() -> void:
	# Sol Principal (Luz direcional com sombras)
	var dir_light = DirectionalLight3D.new()
	dir_light.name = "LuzSolDinamica"
	dir_light.light_color = Color(1.0, 1.0, 0.95)
	dir_light.light_energy = 2.5
	dir_light.shadow_enabled = true
	dir_light.rotation_degrees = Vector3(-50, 30, 0)
	add_child(dir_light)
	
	# Luz de preenchimento frontal (Evita sombras pretas/cinzentas escuras)
	var fill_light = DirectionalLight3D.new()
	fill_light.name = "LuzPreenchimento"
	fill_light.light_color = Color(0.8, 0.9, 1.0)
	fill_light.light_energy = 1.0
	fill_light.rotation_degrees = Vector3(30, -150, 0)
	add_child(fill_light)
	
	print("Iluminação configurada com sucesso!")

# Garante que o modelo tenha cor visível caso venha sem materiais texturizados
func aplicar_material_visivel() -> void:
	var aux_scene = $CharacterBody3D/AuxScene
	for child in aux_scene.find_children("*", "MeshInstance3D", true, false):
		var mesh_inst = child as MeshInstance3D
		if mesh_inst and mesh_inst.material_override == null:
			var mat = StandardMaterial3D.new()
			mat.albedo_color = Color(0.15, 0.55, 0.9) # Azul agradável para visualização
			mat.roughness = 0.4
			mesh_inst.material_override = mat
