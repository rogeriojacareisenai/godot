# Node3D
# -> Camera3D
# -> Character3D
      -> RunningPlace (fbx)
      
extends Node3D

func _ready() -> void:
	var ap: AnimationPlayer = find_child("AnimationPlayer", true, false)
	var anim := "mixamo_com"
	
	if ap and ap.has_animation(anim):
		ap.play(anim)
		ap.get_animation(anim).loop_mode = Animation.LOOP_LINEAR
		msg("Sucesso: Animação '" + anim + "' iniciada!", Color.GREEN)
	else:
		msg("ERRO: AnimationPlayer ou animação '" + anim + "' não encontrada!", Color.RED)

func msg(txt: String, cor: Color) -> void:
	var cl := CanvasLayer.new()
	var lbl := Label.new()
	lbl.text = txt
	lbl.position = Vector2(20, 20)
	lbl.add_theme_color_override("font_color", cor)
	cl.add_child(lbl)
	add_child(cl)
