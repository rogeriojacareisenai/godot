Node3d
 Camera3D
 CharacterBody3D
   -> idle
 CharacterBody3D2
   -> walking




extends Node3D

@onready var c1: Node3D = $CharacterBody3D
@onready var c2: Node3D = $CharacterBody3D2

var ap1: AnimationPlayer
var ap2: AnimationPlayer
var walk: bool = false

func _ready() -> void:
	ap1 = c1.find_child("AnimationPlayer", true, false)
	ap2 = c2.find_child("AnimationPlayer", true, false)
	trocar()

func _input(e: InputEvent) -> void:
	if e is InputEventKey and e.pressed and not e.echo and e.keycode == KEY_T:
		walk = !walk
		trocar()

func trocar() -> void:
	c1.visible = !walk
	c2.visible = walk
	
	if ap1: ap1.stop()
	if ap2: ap2.stop()
	
	var ap = ap2 if walk else ap1
	if ap and ap.has_animation("mixamo_com"):
		# Define o modo de repetição para ciclo contínuo
		ap.get_animation("mixamo_com").loop_mode = Animation.LOOP_LINEAR
		ap.play("mixamo_com")
