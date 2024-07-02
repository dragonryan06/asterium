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
