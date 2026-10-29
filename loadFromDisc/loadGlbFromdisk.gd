extends Node3D

@export_file("*.glb", "*.gltf") var modelo_path: String = "C:/Users/Instrutor/Downloads/idle.glb"
@export var escala: float = 1.0  
@export var distancia_camera: float = 400.0 

func _ready() -> void:
	# 1. Configura Câmera e Luz
	var cam = Camera3D.new(); cam.current = true; cam.position = Vector3(0, 1.5, distancia_camera); cam.look_at(Vector3.ZERO, Vector3.UP); add_child(cam)
	var luz = DirectionalLight3D.new(); luz.rotation_degrees = Vector3(-45, 45, 0); luz.shadow_enabled = true; add_child(luz)

	# 2. Carrega GLB
	var state = GLTFState.new(); var doc = GLTFDocument.new()
	if doc.append_from_file(modelo_path, state) != OK: return
	var modelo = doc.generate_scene(state)
	var raiz = modelo if modelo is Node3D else Node3D.new()
	if modelo and not modelo is Node3D: raiz.add_child(modelo)
	add_child(raiz); raiz.scale = Vector3.ONE * escala

	# 3. Limpa T-pose e Roda Animação em Loop
	for m in raiz.find_children("*", "MeshInstance3D", true, true):
		var p = m.get_parent(); var sk = false
		while p and p != raiz: 
			if p is Skeleton3D: sk = true; break 
			p = p.get_parent()
		if not sk: m.queue_free()

	for p in raiz.find_children("*", "AnimationPlayer", true, true):
		var ap = p as AnimationPlayer; var anims = ap.get_animation_list()
		if not anims.is_empty():
			ap.get_animation(anims[0]).loop_mode = Animation.LOOP_LINEAR
			ap.play(anims[0]); break

