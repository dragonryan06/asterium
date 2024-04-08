extends DialogPanelContainer

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
	
	# Tree.scroll_horizontal and Tree.scroll_vertical are broken in godot 4.2.1, have to crush then reset scale to fix the SolutionInfoPane
	var old_size = size
	size = Vector2(0,0)
	size = old_size


func setup_data(target:CelestialObject) -> void:
	$UpperPanel/VBoxContainer/Title.text = target.obj_name
	$UpperPanel/VBoxContainer/Subtitle.text = target.obj_class
	$InnerPanel/TabContainer/Overview/Panel/RichTextLabel.text = _fill_blanks(text_formats["star"]["overview"],target)
	
	$InnerPanel/TabContainer/Composition/PanelContainer/MarginContainer/VBoxContainer/SolutionInfoPane.setup_data(target.get_node("Composition"))

func _fill_blanks(text:String,target:CelestialObject) -> String:
	while text.find("{")!=-1:
		var val = null
		var varname = text.substr(text.find("{")+1,text.find("}")-text.find("{")-1)
		val = target.get(varname)
		if val is float:
			val = snapped(val,0.001)
		text = text.substr(0,text.find("{"))+str(val)+text.substr(text.find("}")+1)
	return text
