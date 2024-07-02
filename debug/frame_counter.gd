extends RichTextLabel

func _input(event):
	if event.is_action_pressed("toggle_debug_overlay"):
		visible = !visible

func _process(_delta):
	if visible:
		text = "[right]Build: "+str(Engine.get_architecture_name())+"\n"+Constants.version+"\nGodot "+str(Engine.get_version_info().string)+"\n"+str(Engine.get_frames_per_second())+" fps[/right]"
