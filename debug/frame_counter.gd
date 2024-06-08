extends RichTextLabel

const version_num = "v0.0.0 pre-release"

func _input(event):
	if event.is_action_pressed("toggle_debug_overlay"):
		visible = !visible

func _process(_delta):
	if visible:
		text = "[right] System Architecture: "+str(Engine.get_architecture_name())+"\nBuild: "+version_num+"\nGodot "+str(Engine.get_version_info().string)+"\n"+str(Engine.get_frames_per_second())+" fps[/right]"
