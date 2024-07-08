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

func play(scenepath:String) -> void:
	var swoosh = get_tree().create_tween()
	swoosh.tween_property($MainMenu/UI,"offset",Vector2(0,2048),2).set_trans(Tween.TRANS_CUBIC)
	await swoosh.finished
	var fade = get_tree().create_tween()
	fade.tween_property($MainMenu/Camera2D/FTB/ColorRect,"modulate",Color(0,0,0,1),2).set_trans(Tween.TRANS_SINE)
	await fade.finished
	
	var mm = $MainMenu
	remove_child(mm)
	mm.queue_free()
	var scene = load(scenepath).instantiate()
	scene.get_node("Camera2D").enabled = false
	add_child(scene)
	
	await get_tree().create_timer(2)
	
	scene.get_node("Camera2D").enabled = true
