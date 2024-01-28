extends Node2D
class_name GenericObject

## The inspector to send information to
# NOTE assign this value before the object enters tree
var object_inspector : Control
## This objects' name
var obj_title : String
## This objects' type, or classification
var obj_subtitle : String

var hover = false
var inspecting = false

func _show_tooltip():
	if hover:
		object_inspector.show_tooltip(self)

func _on_hitbox_mouse_entered() -> void:
	hover = true
	if not inspecting:
		var timer = get_tree().create_timer(0.5)
		timer.timeout.connect(_show_tooltip)

func _on_hitbox_mouse_exited() -> void:
	hover = false
	object_inspector.hide_tooltip()

func _on_hitbox_input_event(_viewport, event, _shape_idx) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed and Input.is_physical_key_pressed(KEY_SHIFT):
		if not inspecting:
			object_inspector.show_inspect(self)
			inspecting = true
		else:
			object_inspector.hide_inspect()
			inspecting = false
