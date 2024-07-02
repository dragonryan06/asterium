extends Node

func _ready():
	# init userdata settings
	var settings = ResourceManager.get_or_create_settings()
	ProjectSettings.set_setting("display/window/size/mode",settings.get_value("VIDEO","WINDOW_MODE"))
	DisplayServer.window_set_mode(settings.get_value("VIDEO","WINDOW_MODE"))
	ProjectSettings.set_setting("display/window/size/viewport_width",settings.get_value("VIDEO","RESOLUTION").x)
	ProjectSettings.set_setting("display/window/size/viewport_height",settings.get_value("VIDEO","RESOLUTION").y)
	DisplayServer.window_set_size(settings.get_value("VIDEO","RESOLUTION"))
	get_viewport().content_scale_mode = settings.get_value("VIDEO","STRETCH_MODE")
	get_viewport().content_scale_aspect = settings.get_value("VIDEO","STRETCH_ASPECT")
	get_viewport().content_scale_factor = settings.get_value("VIDEO","SCALE_FACTOR")
	get_viewport().content_scale_stretch = settings.get_value("VIDEO","SCALE_STRETCH_MODE")

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
	var PlanetGeneration = load("res://scenes/planet_generation.tscn")
	var pg = PlanetGeneration.instantiate()
	pg.get_node("Camera2D").enabled = false
	add_child(pg)
	
	fade = get_tree().create_tween()
	fade.tween_property($FTB,"color",Color(0,0,0,0),2).set_trans(Tween.TRANS_SINE)
	await fade.finished
	pg.get_node("Camera2D").enabled = true
