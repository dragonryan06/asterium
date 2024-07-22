extends ColorRect
## this screen just tells the user to wait if they attempt to zoom past 1.0/zoom.x==100 

func _ready():
	get_parent().get_parent().get_node("Camera2D").camera_zoom_max.connect(_on_camera_zoom_max)

func _on_camera_zoom_max(state:bool) -> void:
	if state == true:
		visible = true
		var tween = get_tree().create_tween()
		tween.tween_property(self,"modulate",Color(1.0,1.0,1.0,1.0),0.5)
	else:
		var tween = get_tree().create_tween()
		tween.tween_property(self,"modulate",Color(1.0,1.0,1.0,0.0),0.5)
		await tween.finished
		visible = false
