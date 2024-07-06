extends Node2D

func _ready():
	$UI/Version.text = Constants.version

func _on_button_pressed(idx:int):
	match idx:
		0:
			get_parent().play()
		1:
			$UI/Settings.fly_in()
		2:
			get_tree().quit()

func _process(delta):
	$Camera2D.position+=delta*(get_viewport().get_mouse_position()-get_viewport().get_visible_rect().size*Vector2(0.5,0.5))
