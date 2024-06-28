extends Sprite2D

func _ready() -> void:
	find_parent("Camera2D").camera_changed.connect(_on_camera_changed)

func _input(event):
	if event.is_action_pressed("toggle_grid"):
		visible = !visible

func _get_camera_rect() -> Rect2:
	var half_size = get_viewport_rect().size * 0.5 * 1.0/find_parent("Camera2D").zoom.x
	return Rect2(find_parent("Camera2D").global_position-half_size,half_size*2.0)

func _on_camera_changed() -> void:
	var cam = find_parent("Camera2D")
	material.set_shader_parameter("offset",cam.global_position)
	material.set_shader_parameter("zoom",cam.zoom)
	
	var inv_zoom = 1.0/cam.zoom.x
	var au = 1
	if inv_zoom>8.0 and inv_zoom<=25.0:
		au = 2
	elif inv_zoom>25.0 and inv_zoom<=50.0:
		au = 5
	elif inv_zoom>50.0:
		au = 10
	get_parent().get_node("Scale").text = str(int(au))+" AU"
	material.set_shader_parameter("radial_period",1024*au)
