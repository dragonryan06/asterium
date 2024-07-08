extends CanvasLayer
class_name InspectComponent

signal camera_focus_object(obj:Node2D)

@export var trigger_area : CollisionObject2D
@export var can_camera_focus : bool
@export_category("Tooltip")
@export var tt_title_text : String
@export var tt_subtitle_text : String
@export_category("InspectDialog")
@export_file var inspect_dialog_scene

@onready var _Tooltip = preload("res://ui/tooltip.tscn")
@onready var _InspectDialog = load(inspect_dialog_scene)

var hovering = false
var inspecting = false

# ignore signal tooltip_changed because that was us
var _tt_lock = false

static func recolor_icon(tex:Texture2D,color:Color) -> ImageTexture:
	var img = tex.get_image()
	for y in range(img.get_height()):
		for x in range(img.get_width()):
			img.set_pixel(x,y,img.get_pixel(x,y)*color)
	return ImageTexture.create_from_image(img)

func _ready() -> void:
	trigger_area.mouse_entered.connect(_hover_on)
	trigger_area.mouse_exited.connect(_hover_off)
	if can_camera_focus:
		camera_focus_object.connect(get_viewport().get_camera_2d()._on_camera_focus_object.bind(get_parent()))

func _check_mouse_collide() -> bool:
	var pp = PhysicsPointQueryParameters2D.new()
	pp.collide_with_areas = true
	pp.position = trigger_area.get_global_mouse_position()
	var intersect = trigger_area.get_world_2d().direct_space_state.intersect_point(pp,1)
	if not intersect.is_empty() and intersect[0].collider==trigger_area:
		return true
	else:
		return false

func _input(event) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed() and Input.is_physical_key_pressed(KEY_SHIFT):
		if _check_mouse_collide():
			if not inspecting:
				destroy_tooltip()
				create_inspect_dialog()
			elif inspecting:
				if has_node("InspectDialog"):
					destroy_inspect_dialog()
					_hover_on()
			inspecting = !inspecting
	elif event.is_action_pressed("camera_focus_object"):
		if _check_mouse_collide():
			camera_focus_object.emit()

func _hover_on() -> void:
	if not hovering and get_child_count()==0:
		hovering = true
		await get_tree().create_timer(0.5).timeout
		if not inspecting:
			create_tooltip()

func _hover_off() -> void:
	hovering = false
	if get_child_count()>0:
		destroy_tooltip()

func create_tooltip() -> void:
	if has_node("Tooltip"):
		var ot = get_node("Tooltip")
		remove_child(ot)
		ot.queue_free()
	var tt = _Tooltip.instantiate()
	tt.get_node("Text/VBoxContainer/Title").text = tt_title_text
	tt.get_node("Text/VBoxContainer/Subtitle").text = tt_subtitle_text
	tt.position = get_viewport().get_mouse_position()
	add_child(tt)
	_tt_lock = true
	find_parent("Game").get_child(0).find_child("UIManager").tooltip_changed.emit()
	_tt_lock = false
	var tween = get_tree().create_tween()
	tween.tween_property(tt,"modulate",Color(1,1,1,1),0.25)

func destroy_tooltip() -> void:
	if has_node("Tooltip"):
		var tween = get_tree().create_tween()
		var tt = get_node("Tooltip")
		await tween.tween_property(tt,"modulate",Color(1,1,1,0),0.25).finished
		# check that, during the wait, someone else didnt kill the tooltip
		if has_node("Tooltip"):
			remove_child(tt)
			tt.queue_free()

func create_inspect_dialog() -> void:
	var id = _InspectDialog.instantiate()
	id.destroying_dialog.connect(id.connecting_line._fade_out_and_die)
	add_child(id)
	id.name = "InspectDialog"
	id.position = get_viewport().get_mouse_position()
	id.connecting_target = get_parent()
	id.setup_data(get_parent())
	var tween = get_tree().create_tween()
	tween.tween_property(id,"modulate",Color(1,1,1,1),0.25)

func destroy_inspect_dialog() -> void:
	var id = get_node("InspectDialog")
	id.destroying_dialog.emit()
	var tween = get_tree().create_tween()
	await tween.tween_property(id,"modulate",Color(1,1,1,0),0.25).finished
	remove_child(id)
	id.queue_free()

func _on_tooltip_changed() -> void:
	if not _tt_lock:
		destroy_tooltip()

func _on_tree_entered():
	find_parent("Game").get_child(0).find_child("UIManager").tooltip_changed.connect(_on_tooltip_changed)
