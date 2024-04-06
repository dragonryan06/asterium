extends DialogPanelContainer

const text_formats = {
	"star": {
		"overview":"[b][u]Rotational Period[/u] :[/b] {rotational_period} d\n[b][u]Chromaticity[/u] :[/b] [color={chromaticity_color}]{chromaticity}[/color]\n[b][u]Surface Temperature[/u] :[/b] {temperature} K\n[b][u]Radius[/u] :[/b] {radius} R*\n[b][u]Mass[/u] :[/b] {mass} M*",
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


func setup_data(target:CelestialObject) -> void:
	$UpperPanel/VBoxContainer/Title.text = target.obj_name
	$UpperPanel/VBoxContainer/Subtitle.text = target.obj_class
	$InnerPanel/TabContainer/Overview/Panel/RichTextLabel.text = _fill_blanks(text_formats["star"]["overview"],target)
	
	_make_composition_tree(target)

func _fill_blanks(text:String,target:CelestialObject) -> String:
	while text.find("{")!=-1:
		var val = null
		var varname = text.substr(text.find("{")+1,text.find("}")-text.find("{")-1)
		val = target.get(varname)
		if val is float:
			val = snapped(val,0.001)
		text = text.substr(0,text.find("{"))+str(val)+text.substr(text.find("}")+1)
	return text

func _make_composition_tree(target:CelestialObject) -> void:
	var comp_tree = $InnerPanel/TabContainer/Composition/Panel/Tree
	comp_tree.clear()
	if comp_tree.item_activated.is_connected(_on_comp_tree_item_activated):
		comp_tree.item_activated.disconnect(_on_comp_tree_item_activated)
	comp_tree.item_activated.connect(_on_comp_tree_item_activated.bind(comp_tree,target))
	comp_tree.columns = 2
	var root = comp_tree.create_item()
	comp_tree.hide_root = true
	for c in target.get_children():
		match c.name:
			"Surface","Ocean","Atmosphere","Composition":
				var item = comp_tree.create_item(root)
				item.set_text(0,c.name)
				item.set_custom_font_size(0,24)
				item.set_custom_color(0,Color("#ffffff"))
				item.set_selectable(0,false)
			"Satellites":
				pass

func _on_comp_tree_item_activated(comp_tree:Tree,obj:CelestialObject) -> void:
	var selected = comp_tree.get_selected().get_text(0)
	if obj.has_node("Satellites"):
		for s in obj.get_node("Satellites").get_children():
			if s.obj_title == selected:
				get_parent().camera_focus_object.emit(s)
