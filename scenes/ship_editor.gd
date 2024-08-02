extends Node2D

const hotbar = [KEY_1,KEY_2,KEY_3,KEY_4,KEY_5,KEY_6,KEY_7,KEY_8,KEY_9]

enum STYLES {
	STRAIGHTAWAY,
	ELBOW,
	T_INTERSECTION,
	FOURWAY,
	HALF_ELBOW,
	DIAGONAL,
	DIAGONAL_FOURWAY,
	Y_INTERSECT
}
var style_selection = -1

var action_history = []
var action_idx = -1

var selected = ""
var drag_path = []
var drawing_path = false
var erasing = false

#func _process(delta):
	#print(str(action_history)+"     "+str(action_idx))

func store_action(what:Dictionary) -> void:
	if action_idx<-1:
		# wipe future actions if a new one occurs
		for a in range(len(action_history)+action_idx+1,len(action_history)):
			if a>=0:
				action_history.remove_at(len(action_history)+action_idx+1)
			else:
				action_history.clear()
		action_idx = -1
	action_history.append(what)

func log_action(text:String) -> void:
	var label = Label.new()
	label.text = text
	label.set_meta("fast_fading",false)
	$HUD/ActionLog.add_child(label)
	
	var kill = func(x) -> void:
		if is_instance_valid(x) and x.get_parent()==$HUD/ActionLog:
			$HUD/ActionLog.remove_child(x)
			x.queue_free()
	var fade = get_tree().create_tween()
	fade.tween_property(label,"modulate",Color(1.0,1.0,1.0,0.0),8).set_trans(Tween.TRANS_CUBIC)
	fade.tween_callback(kill.bind(label))
	
	if $HUD/ActionLog.get_child_count()>3:
		for c in $HUD/ActionLog.get_children():
			if c.get_index()<$HUD/ActionLog.get_child_count()-3 and not c.get_meta("fast_fading"):
				c.set_meta("fast_fading",true)
				var fastfade = get_tree().create_tween()
				fastfade.tween_property(c,"modulate",Color(1.0,1.0,1.0,0.0),2).set_trans(Tween.TRANS_CUBIC)
				fastfade.tween_callback(kill.bind(c))

func _input(event:InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		if event.keycode in hotbar:
			_on_hotbar_button_pressed(hotbar.find(event.keycode))
		elif event.is_action_pressed("editor_undo_previous_action"):
			if abs(action_idx-1)<=len(action_history)+1:
				action_idx-=1
		elif event.is_action_pressed("editor_redo_following_action"):
			if action_idx<-1:
				action_idx+=1
		elif event.keycode == KEY_SPACE:
			store_action({"hey someone pressed":"the spacebar lol"})

func _unhandled_input(event:InputEvent) -> void:
	var map = $Ship/TileMap
	if event is InputEventMouseButton:
		match event.button_index:
			MOUSE_BUTTON_LEFT when event.pressed and style_selection == -1:
				# start path-painting
				map.set_layer_modulate(1,Color(0.0,1.0,0.0))
				var pos = map.local_to_map(get_global_mouse_position())
				map.set_cell(1,pos,0,Vector2i(0,0))
				drag_path.append(pos)
				drawing_path = true
			MOUSE_BUTTON_LEFT when not event.pressed and style_selection == -1:
				# stop path-painting
				map.clear_layer(1)
				for c in drag_path:
					map.set_cell(0,c,0,Vector2i(0,0))
				map.set_cells_terrain_path(0,drag_path,0,0)
				drag_path.clear()
				drawing_path = false
			MOUSE_BUTTON_RIGHT when event.pressed:
				# start erasing
				map.set_layer_modulate(1,Color(1.0,0.0,0.0))
				var pos = map.local_to_map(get_global_mouse_position())
				if pos in map.get_used_cells(0):
					map.set_cell(1,pos,0,map.get_cell_atlas_coords(0,pos))
				erasing = true
			MOUSE_BUTTON_RIGHT when not event.pressed:
				# stop erasing
				for c in map.get_used_cells(1):
					map.set_cell(0,c,-1)
				map.clear_layer(1)
				erasing = false
	
	elif event is InputEventMouseMotion:
		var pos = map.local_to_map(get_global_mouse_position())
		if drawing_path and pos!=drag_path[-1]:
			map.set_cell(1,pos,0,Vector2i(0,0))
			drag_path.append(pos)
			map.set_cells_terrain_path(1,drag_path,0,0)
		elif erasing:
			if pos in map.get_used_cells(0):
				map.set_cell(1,pos,0,map.get_cell_atlas_coords(0,pos))

func _on_hotbar_button_pressed(idx:int) -> void:
	var item = $HUD/MarginContainer/Hotbar.get_child(idx).get_meta("select_name")
	if selected == item:
		selected = ""
		log_action("Select: None")
		$HUD/StylePicker.visible = false
	else:
		selected = item
		log_action("Select: "+selected.capitalize())
		$HUD/StylePicker.visible = true
		if style_selection!=-1:
			var button = $HUD/StylePicker/MarginContainer/VBoxContainer/MarginContainer/GridContainer.get_child(style_selection)
			button.set_pressed_no_signal()
			button.get_child(0).visible = false
			style_selection = -1

func _on_style_picker_button_toggled(state:bool,idx:int) -> void:
	var grid = $HUD/StylePicker/MarginContainer/VBoxContainer/MarginContainer/GridContainer
	grid.get_child(idx).get_child(0).visible = state
	if style_selection == -1:
		style_selection = idx
	elif style_selection == idx:
		style_selection = -1
	else:
		style_selection = idx
		for c in grid.get_children():
			if c.get_index()==idx:
				continue
			c.set_pressed_no_signal(false)
			c.get_child(0).visible = false
