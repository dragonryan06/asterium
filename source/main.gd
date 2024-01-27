extends Node

func play() -> void:
	var swoosh = get_tree().create_tween()
	swoosh.tween_property($"Main Menu/UI/Control","position",Vector2(0,-555),2).set_trans(Tween.TRANS_CUBIC)
	await swoosh.finished
	var fade = get_tree().create_tween()
	fade.tween_property($FTB,"color",Color(0,0,0,1),2).set_trans(Tween.TRANS_SINE)
	await fade.finished
	
	var mm = $"Main Menu"
	remove_child(mm)
	mm.queue_free()
	var PlanetGeneration = load("res://source/planet_generation.tscn")
	var pg = PlanetGeneration.instantiate()
	pg.get_node("Camera2D").enabled = false
	add_child(pg)
	
	fade = get_tree().create_tween()
	fade.tween_property($FTB,"color",Color(0,0,0,0),2).set_trans(Tween.TRANS_SINE)
	await fade.finished
	pg.get_node("Camera2D").enabled = true
