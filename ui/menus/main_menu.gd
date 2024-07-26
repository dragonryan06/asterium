extends Node2D

func _ready():
	$UI/Version/Asterium.text = Constants.version
	$UI/Version/Godot.text = "Godot Engine "+Engine.get_version_info().string

func _on_button_pressed(idx:int):
	match idx:
		0:
			# Play
			var tween = get_tree().create_tween().set_parallel()
			tween.tween_property($UI/TopPage,"position",Vector2(333,2048),2).set_trans(Tween.TRANS_CUBIC)
			tween.tween_property($UI/SelectPage,"position",Vector2(333,0),2).set_trans(Tween.TRANS_CUBIC)
		1:
			# Settings
			$UI/Settings.fly_in()
		2:
			# Quit
			get_tree().quit()
		3:
			# Planet generation test
			get_parent().play("res://scenes/planet_generation.tscn")
		4:
			# Ship physics test
			get_parent().play("res://scenes/ship_editor.tscn")
		5:
			# Back
			var tween = get_tree().create_tween().set_parallel()
			tween.tween_property($UI/TopPage,"position",Vector2(333,0),2).set_trans(Tween.TRANS_CUBIC)
			tween.tween_property($UI/SelectPage,"position",Vector2(333,-2048),2).set_trans(Tween.TRANS_CUBIC)

func _process(delta):
	$Camera2D.position+=delta*(get_viewport().get_mouse_position()-get_viewport().get_visible_rect().size*Vector2(0.5,0.5))
