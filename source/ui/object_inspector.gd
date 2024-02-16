extends Control
#
#const formats = {
	#"star": {
		#"details":"[u]Rotational Period:[/u] {rotational_period} d\n[u]Chromaticity:[/u] {chromaticity}\n[u]Surface Temperature:[/u] {temperature} K\n[u]Radius:[/u] {radius} R*\n[u]Mass:[/u] {mass} M*",
		#"description":"\t{obj_title} is a large sphere composed of plasma. It is constantly fusing atoms together, converting a fraction of their mass into energy each time. \n\tIt is the heart of the {obj_title} system, and provides the {chromaticity} illumination seen in its satellites' skies"
	#},
	#"terrestrial_planet": {
		#"details":"[u]Rotational Period:[/u] {rotational_period} d\n[u]Parent Rock:[/u] {parent_rock.name}\n[u]Temperature:[/u] {base_temperature} K\n[u]Ocean:[/u] {liquid_composition.solvent}\n[u]Ocean Coverage:[/u] {liquid_surface_coverage}",
		#"description":"\t{obj_title} is a planet"
	#}
#}
## format notation:
## {xyz} = obj.get(xyz)
## {xyz.abc} = obj.get(xyz).get(abc)
## {$Node.abc} = obj.get_node(Node).get(abc)
## {$Node$*N.abc} = obj.get_node(Node).get_child(N).get(abc)
const formats = {
	"star": {
		"overview":"[b][u]Rotational Period[/u] :[/b] {rotational_period} d\n[b][u]Chromaticity[/u] :[/b] {chromaticity}\n[b][u]Surface Temperature[/u] :[/b] {temperature} K\n[b][u]Radius[/u] :[/b] {radius} R*\n[b][u]Mass[/u] :[/b] {mass} M*",
		"description":"\t {obj_title} is a large sphere made of [u][color={$Composition$*0.item_color}]{$Composition$*0.name}[/color][/u]. Immense heat and pressure from its huge mass has started a process of constant nuclear fusion, merging atoms together and converting a fraction of their mass into energy which it radiates into nearby space. \n\tIt is the heart of the {obj_title} system, providing the {chromaticity} illumination seen in its satellites skies, and the temperature to their surfaces in a phenomenon known as 'daytime'."
	}
}

var inspecting = false
var dragging = false

func _ready():
	$InspectCelestial/TabContainer.tab_focus_mode = 0
	for i in range($InspectCelestial/TabContainer.get_child_count()):
		$InspectCelestial/TabContainer.set_tab_title(i,"")
	var tex = AtlasTexture.new()
	tex.atlas = load("res://assets/ui/inspector_tab_icons.png")
	tex.region = Rect2(0,24,24,24)
	$InspectCelestial/TabContainer.set_tab_icon(0,tex)
	tex = tex.duplicate()
	tex.region = Rect2(24,0,24,24)
	$InspectCelestial/TabContainer.set_tab_icon(1,tex)
	tex = tex.duplicate()
	tex.region = Rect2(24,24,24,24)
	$InspectCelestial/TabContainer.set_tab_icon(2,tex)
	tex = tex.duplicate()
	tex.region = Rect2(0,0,24,24)
	$InspectCelestial/TabContainer.set_tab_icon(3,tex)

func show_inspect(obj:GenericObject) -> void:
	if $Tooltip.modulate.a==1:
		hide_tooltip()
	if obj is CelestialObject:
		$InspectCelestial.position = Vector2(obj.get_global_transform_with_canvas().origin.x+$InspectCelestial.size.x,obj.get_global_transform_with_canvas().origin.y-0.5*$InspectCelestial.size.y)
		$InspectCelestial/Title.text = obj.obj_title
		$InspectCelestial/Subtitle.text = obj.obj_subtitle
		
		if obj is Star:
			$InspectCelestial/TabContainer/Overview/Panel/RichTextLabel.text = formatify(formats["star"]["overview"],obj)
			$InspectCelestial/TabContainer/Description/Panel/RichTextLabel.text = formatify(formats["star"]["description"],obj)
		
		var tween = get_tree().create_tween().set_parallel()
		tween.tween_property($InspectCelestial,"modulate",Color(1,1,1,1),0.25)

func formatify(text:String,obj:Node) -> String:
	while text.find("{")!=-1:
		var val = null
		var varname = text.substr(text.find("{")+1,text.find("}")-text.find("{")-1)
		var last_obj = null
		if varname.begins_with("$"):
			last_obj = obj
			if varname.substr(1).find("$")==-1:
				obj = obj.get_node(varname.substr(1,varname.find(".")-1))
			elif varname.substr(1).find("$*"):
				obj = obj.get_node(varname.substr(1,varname.find("$*")-1)).get_child(int(varname.substr(varname.find("$*")+2,1)))
		while varname.find(".")!=-1:
			if val!=null:
				val = val.get(varname.split(".")[0])
			else:
				val = obj.get(varname.split(".")[1])
			varname = varname.substr(varname.find(".")+1)
		if varname.find(".")==-1:
			val = obj.get(varname)
		if val is float:
			val = snapped(val,0.001)
		if val is Color:
			val = "#"+val.to_html(false)
		text = text.substr(0,text.find("{"))+str(val)+text.substr(text.find("}")+1)
		if last_obj!=null:
			obj = last_obj
			last_obj = null
	return text

func hide_inspect() -> void:
	var tween = get_tree().create_tween().set_parallel()
	tween.tween_property($InspectCelestial,"modulate",Color(1,1,1,0),0.25)
	await tween.finished
	$InspectCelestial.position = -$InspectCelestial.size

func show_tooltip(obj:GenericObject) -> void:
	$Tooltip.position = get_global_mouse_position()
	$Tooltip/Title.text = obj.obj_title
	$Tooltip/Subtitle.text = obj.obj_subtitle
	var tween = get_tree().create_tween()
	tween.tween_property($Tooltip,"modulate",Color(1,1,1,1),0.25)

func hide_tooltip() -> void:
	var tween = get_tree().create_tween()
	tween.tween_property($Tooltip,"modulate",Color(1,1,1,0),0.25)
	await tween.finished
	$Tooltip.position = -$Tooltip.size
