@icon("res://editor/Global.svg")
extends Node
class_name ResourceManager

static func load_json(filepath:String) -> JSON:
	var f = FileAccess.open(filepath, FileAccess.READ)
	var json = JSON.new()
	var error = json.parse(f.get_as_text())
	if error == OK:
		return json
	else:
		print("JSON Parse Error: ",json.get_error_message()," in ",filepath)
		return JSON.new()

static func get_or_create_settings() -> ConfigFile:
	var config = ConfigFile.new()
	var err = config.load("user://settings.cfg")
	if err != OK:
		config.set_value("VIDEO","WINDOW_MODE",DisplayServer.WINDOW_MODE_WINDOWED)
		config.set_value("VIDEO","RESOLUTION",Vector2(1152,648))
		config.set_value("VIDEO","STRETCH_MODE",Window.CONTENT_SCALE_MODE_VIEWPORT)
		config.set_value("VIDEO","STRETCH_ASPECT",Window.CONTENT_SCALE_ASPECT_KEEP)
		config.set_value("VIDEO","SCALE_FACTOR",1.0)
		config.set_value("VIDEO","SCALE_STRETCH_MODE",Window.CONTENT_SCALE_STRETCH_FRACTIONAL)
		config.save("user://settings.cfg")
	return config
