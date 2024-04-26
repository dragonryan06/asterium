extends Line2D
class_name ConnectingLine

# NOTE: ConnectingLine will always float up to the top active scene's 'Background' CanvasLayer when added to any node.
# im thinking there will be more nodes like this later, could call them Annotations or something
# debug lines could work like this too, i just really like the Line2D node over having to spam queue_redraw to draw manually, feels more efficent

func _ready() -> void:
	var current_scene = get_tree().current_scene
	get_parent().remove_child.call_deferred(self)
	current_scene.get_node("Background").add_child.call_deferred(self)
	modulate=Color("#dcdcdc")

func _fade_out_and_die() -> void:
	var tween = get_tree().create_tween()
	await tween.tween_property(self,"modulate",Color(1,1,1,0),0.25).finished
	get_parent().remove_child(self)
	queue_free()

func connect_nodes(node_a:CanvasItem,node_b:CanvasItem) -> void:
	clear_points()
	# Controls need to find center of rect, Node2Ds should be centered
	if node_a is Control:
		add_point(to_local(node_a.get_global_rect().get_center()))
	else:
		add_point(to_local(node_a.get_global_transform_with_canvas().get_origin()))
	
	var create_offset_point = func(pos) -> void:
		var pos_diff = points[0].x-pos.x
		add_point(Vector2(points[0].x-pos_diff*0.5,points[0].y))
	
	if node_b is Control:
		var pos = to_local(node_b.get_global_rect().get_center())
		create_offset_point.call(pos)
		add_point(pos)
	else:
		var pos = to_local(node_b.get_global_transform_with_canvas().get_origin())
		create_offset_point.call(pos)
		add_point(pos)
