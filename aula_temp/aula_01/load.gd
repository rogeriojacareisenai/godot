extends Node3D

@onready var ap: AnimationPlayer = find_child("AnimationPlayer", true, false)

func _ready() -> void:
	criar_ambiente()
	if ap:
		ap.active = true
		for anim in ["walking", "idle"]:
			if ap.has_animation(anim): ap.get_animation(anim).loop_mode = Animation.LOOP_LINEAR
		tocar_animacao("idle")
		mostrar_mensagem("Sucesso: Pronto!", Color.GREEN)
	else:
		mostrar_mensagem("ERRO: AnimationPlayer ausente!", Color.RED)

func _process(_delta: float) -> void:
	if not ap: return
	
	var dir := Vector3(
		Input.get_axis("ui_left", "ui_right"),
		0,
		Input.get_axis("ui_up", "ui_down")
	)
	
	if dir != Vector3.ZERO:
		rotation.y = atan2(dir.x, dir.z)
		tocar_animacao("walking")
	else:
		tocar_animacao("idle")

func tocar_animacao(nome: String) -> void:
	if ap and ap.has_animation(nome) and ap.current_animation != nome:
		ap.play(nome)
		if nome == "walking": ap.seek(0, true)

func criar_ambiente() -> void:
	var chao = StaticBody3D.new()
	var mesh = MeshInstance3D.new()
	mesh.mesh = PlaneMesh.new()
	mesh.mesh.size = Vector2(1000, 1000)
	
	var col = CollisionShape3D.new()
	col.shape = BoxShape3D.new()
	col.shape.size = Vector3(1000, 0.1, 1000)
	
	chao.add_child(mesh)
	chao.add_child(col)
	add_child(chao)
	
	var luz = DirectionalLight3D.new()
	luz.light_energy = 1.5
	luz.shadow_enabled = true
	luz.rotation_degrees = Vector3(-45, 45, 0)
	add_child(luz)

func mostrar_mensagem(texto: String, cor: Color) -> void:
	var c = CanvasLayer.new()
	var l = Label.new()
	l.text = texto
	l.position = Vector2(20, 20)
	l.add_theme_color_override("font_color", cor)
	c.add_child(l)
	add_child(c)
