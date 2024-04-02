extends CanvasLayer
class_name InspectComponent

@export var trigger_area : CollisionObject2D
@export_category("Tooltip")
@export var tt_title_text : String
@export var tt_subtitle_text : String
@export_category("InspectDialog")

@onready var _Tooltip = preload("res://ui/tooltip.tscn")

var hovering = false
var inspecting

func _ready():
	trigger_area.mouse_entered.connect(_hover_on)
	trigger_area.mouse_exited.connect(_hover_off)

func _input(event):
	if hovering:
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed() and Input.is_physical_key_pressed(KEY_SHIFT):
			

func _hover_on():
	if not hovering and get_child_count()==0:
		hovering = true
		await get_tree().create_timer(0.5).timeout
		var tt = _Tooltip.instantiate()
		tt.get_node("Text/VBoxContainer/Title").text = tt_title_text
		tt.get_node("Text/VBoxContainer/Subtitle").text = tt_subtitle_text
		tt.position = get_viewport().get_mouse_position()
		add_child(tt)
		var tween = get_tree().create_tween()
		tween.tween_property(tt,"modulate",Color(1,1,1,1),0.25)

func _hover_off():
	hovering = false
	if get_child_count()>0:
		var tween = get_tree().create_tween()
		await tween.tween_property(get_child(0),"modulate",Color(1,1,1,0),0.25).finished
		var c = get_child(0)
		remove_child(c)
		c.queue_free()
