extends Node2D

const hotbar = [KEY_1,KEY_2,KEY_3,KEY_4,KEY_5,KEY_6,KEY_7,KEY_8,KEY_9]

func _input(event:InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode in hotbar:
		_on_hotbar_button_pressed(hotbar.find(event.keycode))

func _on_hotbar_button_pressed(idx:int) -> void:
	print("hotbar button "+str(idx))
