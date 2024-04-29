extends DialogPanelContainer

@onready var _SolutionInfoDialog = preload("res://ui/dialogs/solution_info_dialog.tscn")

@onready var matter_icons = preload("res://ui/assets/matterstate_icons.png")
@onready var celestial_icons = preload("res://ui/assets/celestialobject_icons.png")
@onready var unknown_icon = preload("res://ui/assets/question_icon.png")
@onready var solution_icon = preload("res://ui/assets/solution_icon.png")

const text_formats = {
	"star": {
		"overview":"[color=#dddddd][b]Rotational Period:[/b][/color] {rotational_period} [color=#acacac]d[/color]\n[color=#dddddd][b]Chromaticity:[/b][/color] [color={chromaticity_color}]{chromaticity}[/color]\n[color=#dddddd][b]Surface Temperature:[/b][/color] {temperature} [color=#acacac]K[/color]\n[color=#dddddd][b]Radius:[/b][/color] {radius} [color=#acacac]R*[/color]\n[color=#dddddd][b]Mass:[/b][/color] {mass} [color=#acacac]M*[/color]",
		# description would go here but i think it would be better to have the objects generate that for themselves and store it.
	}
}

@onready var icons = preload("res://ui/assets/inspector_tab_icons.png")
@onready var star_spectrum = preload("res://core/space/star_spectrum.tres")

func _ready() -> void:
	$InnerPanel/TabContainer.tab_focus_mode = 0
	for i in range($InnerPanel/TabContainer.get_child_count()):
		$InnerPanel/TabContainer.set_tab_title(i,"")
	var tex = AtlasTexture.new()
	tex.atlas = icons
	tex.region = Rect2(0,24,24,24)
	$InnerPanel/TabContainer.set_tab_icon(0,tex)
	tex = tex.duplicate()
	tex.region = Rect2(24,0,24,24)
	$InnerPanel/TabContainer.set_tab_icon(1,tex)
	tex = tex.duplicate()
	tex.region = Rect2(24,24,24,24)
	$InnerPanel/TabContainer.set_tab_icon(2,tex)
	tex = tex.duplicate()
	tex.region = Rect2(0,0,24,24)
	$InnerPanel/TabContainer.set_tab_icon(3,tex)
	
	destroying_subdialog.connect(_on_destroying_subdialog)
	destroying_dialog.connect(_on_destroying_subdialog.bind(null))

func setup_data(target:CelestialObject) -> void:
	$UpperPanel/VBoxContainer/Title.text = target.obj_name
	$UpperPanel/VBoxContainer/Subtitle.text = target.obj_class
	$InnerPanel/TabContainer/Overview/Panel/RichTextLabel.text = _fill_blanks(text_formats["star"]["overview"],target)
	
	var composition_container = $InnerPanel/TabContainer/Composition/PanelContainer/MarginContainer/VBoxContainer
	var base = composition_container.get_node("SolutionName")
	for c in target.get_children():
		if c is Solution:
			var comp_node = base.duplicate()
			comp_node.get_node("MarginContainer/HBoxContainer/VBoxContainer/Header").text="[b]"+c.name+"[/b]"
			comp_node.get_node("MarginContainer/HBoxContainer/VBoxContainer/Footer").text = "[color="+c.solution_color.to_html()+"]"+c.solution_name+"[/color]"
			comp_node.get_node("MarginContainer/HBoxContainer/AspectRatioContainer/TextureRect").texture = InspectComponent.recolor_icon(Reagent.get_state_icon(c.get_largest_component()),c.solution_color)
			comp_node.get_node("MarginContainer/HBoxContainer/TextureButton").pressed.connect(_on_comp_node_inspect.bind(c))
			composition_container.add_child(comp_node)
	composition_container.remove_child(base)
	base.queue_free()

func _on_comp_node_inspect(solution:Solution) -> void:
	var dialog = get_node_or_null(NodePath("Subdialogs/"+solution.name))
	if dialog!=null:
		destroying_subdialog.emit(dialog)
		var tween = get_tree().create_tween()
		await tween.tween_property(dialog,"modulate",Color(1,1,1,0),0.25).finished
		$Subdialogs.remove_child(dialog)
		dialog.queue_free()
	else:
		dialog = _SolutionInfoDialog.instantiate()
		dialog.name = solution.name
		dialog.setup_data(solution)
		dialog.position = get_global_mouse_position()-Vector2(100,100)
		dialog.connecting_target=self
		$Subdialogs.add_child(dialog)
	return

func _on_destroying_subdialog(which:DialogPanelContainer) -> void:
	if which==null:
		# if the parent dialog is dying, this method is called with null, so we kill all connectors
		for c in $Subdialogs.get_children():
			if "connecting_line" in c:
				c.connecting_line._fade_out_and_die()
	else:
		which.connecting_line._fade_out_and_die()

func _fill_blanks(text:String,target:CelestialObject) -> String:
	while text.find("{")!=-1:
		var val = null
		var varname = text.substr(text.find("{")+1,text.find("}")-text.find("{")-1)
		val = target.get(varname)
		if val is float:
			val = snapped(val,0.001)
		text = text.substr(0,text.find("{"))+str(val)+text.substr(text.find("}")+1)
	return text
