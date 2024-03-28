extends Node2D

func _on_play_button_mouse_entered():
	$UI/Control/PlayButton/PLAY.modulate = Color(1.0,0.0,0.0,1.0)

func _on_play_button_mouse_exited():
	$UI/Control/PlayButton/PLAY.modulate = Color(1.0,1.0,1.0,1.0)

func _on_play_button_pressed():
	$UI/Control/PlayButton/PLAY.modulate = Color(1.0,0.0,0.0,1.0)
	$UI/Control/PlayButton.disabled = true
	get_parent().play()
