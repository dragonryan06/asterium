extends Node

static func load_json(filepath:String) -> JSON:
	var f = FileAccess.open(filepath, FileAccess.READ)
	var json = JSON.new()
	var error = json.parse(f.get_as_text())
	if error == OK:
		return json
	else:
		print("JSON Parse Error: ",json.get_error_message()," in ",filepath)
		return JSON.new()
