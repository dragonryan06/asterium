extends ParallaxBackground

var last_zoom = Vector2(1,1)

func _ready() -> void:
	if "camera_changed" in get_parent():
		get_parent().camera_changed.connect(_on_camera_changed)

func _get_camera_rect() -> Rect2:
	var half_size = get_child(0).get_viewport_rect().size * 0.5 * 1.0/find_parent("Camera2D").zoom.x
	return Rect2(find_parent("Camera2D").global_position-half_size,half_size*2.0)

func _on_camera_changed() -> void:
	#pass
	if get_parent().zoom!=last_zoom:
		for c in get_children():
			if c.name==&"Background":
				continue
			#c.motion_offset = c.get_viewport_rect().size*0.5*pow(1-c.motion_scale.x,1)*(1.0 + 1.0/get_parent().zoom.x)
			#c.motion_offset = c.get_viewport_rect().size*0.5*(Vector2.ONE/c.motion_scale-Vector2.ONE)
			#print(c.motion_offset)
			c.motion_offset+=motion_scale*(Vector2.ONE/get_parent().zoom)
