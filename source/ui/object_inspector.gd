extends Control

@onready var matter_icons = preload("res://assets/ui/matterstate_icons.png")
@onready var celestial_icons = preload("res://assets/ui/celestialobject_icons.png")

## format notation:
## {xyz} = obj.get(xyz)
## {xyz.abc} = obj.get(xyz).get(abc)
## {$Node.abc} = obj.get_node(Node).get(abc)
## {$Node$*N.abc} = obj.get_node(Node).get_child(N).get(abc)
const formats = {
	"star": {
		"overview":"[b][u]Rotational Period[/u] :[/b] {rotational_period} d\n[b][u]Chromaticity[/u] :[/b] {chromaticity}\n[b][u]Surface Temperature[/u] :[/b] {temperature} K\n[b][u]Radius[/u] :[/b] {radius} R*\n[b][u]Mass[/u] :[/b] {mass} M*",
		"description":"\t {obj_title} is a large sphere made of [u][color={$Composition$*0.item_color}]{$Composition$*0.name}[/color][/u]. Immense heat and pressure from its huge mass has started a process of constant nuclear fusion, merging atoms together and converting a fraction of their mass into energy which it radiates into nearby space. \n\tIt is the heart of the {obj_title} system, providing the {chromaticity} illumination seen in its satellites skies, and the temperature to their surfaces in a phenomenon known as 'daytime'."
	},
	"terrestrial_planet": {
		"overview":"[b][u]Rotational Period:[/u] :[/b] {rotational_period} d\n[b][u]Orbital Radius[/u] :[/b] {orbital_radius} AU\n[b][u]Temperature:[/u] :[/b] {base_temperature} K\n[b][u]Ocean Coverage[/u] :[/b] {ocean_coverage_percent}%",
		"description":"\t {obj_title} is a rocky planet, primarily made of [u][color={$Composition/Surface$*0.item_color}]{$Composition/Surface$*0.name}[/color][/u].\n\tIt has seas of [u][color={$Composition/Ocean$*0.item_color}]{$Composition/Ocean$*0.name}[/color][/u] that cover {ocean_coverage_percent}% of its surface."
	} # gonna need to change this system or something to allow conditional changes. Right now there's no way to check if the ocean has completely boiled off and say something different for that.
}

var inspecting = false
var dragging = false

static func recolor_icon(tex:Texture2D,color:Color) -> ImageTexture:
	var img = tex.get_image()
	for y in range(img.get_height()):
		for x in range(img.get_width()):
			img.set_pixel(x,y,img.get_pixel(x,y)*color)
	return ImageTexture.create_from_image(img)

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
			make_composition_tree(obj)
			$InspectCelestial/TabContainer/Properties/Panel/RichTextLabel.text = "[b]Object Tags:[/b]\n"+str(obj.tags).replace("[","").replace("]","").replace(",","\n")
		elif obj is TerrestrialPlanet:
			$InspectCelestial/TabContainer/Overview/Panel/RichTextLabel.text = formatify(formats["terrestrial_planet"]["overview"],obj)
			make_composition_tree(obj)
			$InspectCelestial/TabContainer/Properties/Panel/RichTextLabel.text = "[b]Object Tags:[/b]\n"+str(obj.tags).replace("[","").replace("]","").replace(",","\n")
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
				if obj.get_node(varname.substr(1,varname.find("$*")-1)).get_child_count()-1==int(varname.substr(varname.find("$*")+2,1)):
					obj = obj.get_node(varname.substr(1,varname.find("$*")-1)).get_child(int(varname.substr(varname.find("$*")+2,1)))
				else:
					obj = null
		while varname.find(".")!=-1:
			if val!=null:
				val = val.get(varname.split(".")[0])
			else:
				if obj!=null:
					val = obj.get(varname.split(".")[1])
				else:
					val = null
			varname = varname.substr(varname.find(".")+1)
		if varname.find(".")==-1:
			if obj!=null:
				val = obj.get(varname)
			else:
				val = null
		if val is float:
			val = snapped(val,0.001)
		if val is Color:
			val = "#"+val.to_html(false)
		if val is StringName:
			val = val.replace("_"," ")
		if varname.find("_percent")!=-1:
			val*=100.0
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

func make_composition_tree(obj:GenericObject) -> void:
	var comp_tree = $InspectCelestial/TabContainer/Composition/Panel/Tree
	comp_tree.clear()
	if comp_tree.item_activated.is_connected(_on_comp_tree_item_activated):
		comp_tree.item_activated.disconnect(_on_comp_tree_item_activated)
	comp_tree.item_activated.connect(_on_comp_tree_item_activated.bind(comp_tree,obj))
	comp_tree.columns = 2
	var root = comp_tree.create_item()
	comp_tree.hide_root = true
	for i in obj.get_children():
		if i is Sprite2D:
			continue
		var item = comp_tree.create_item(root)
		item.set_text(0,i.name)
		item.set_custom_font_size(0,24)
		item.set_custom_color(0,Color("#ffffff"))
		item.set_selectable(0,false)
		if i.name=="Composition":
			item.set_custom_color(1,Color("#ffffff"))
			item.set_selectable(1,false)
			item.set_text(1,"%")
		elif i.name=="Satellites":
			item.set_custom_color(1,Color("#ffffff"))
			item.set_selectable(1,false)
			item.set_text(1,"dist.")
		for o in i.get_children():
			var subitem = comp_tree.create_item(item)
			if "item_color" in o:
				subitem.set_custom_color(0,o.item_color)
				create_substance_tree_item(subitem,o)
			if o is CelestialObject:
				subitem.set_text(1,str(snapped(o.orbital_radius,0.01))+" AU")
				subitem.set_selectable(1,false)
				var rect:Rect2i
				if o is TerrestrialPlanet:
					rect = Rect2i(0,0,18,18)
				elif o is Star:
					rect = Rect2i(18,18,18,18)
				# add asteroids/rings and gasplanet here
				var tex = AtlasTexture.new()
				tex.atlas = celestial_icons
				tex.region = rect
				subitem.set_icon(0,tex)
			elif o.name=="Surface" or o.name=="Ocean" or o.name=="Atmosphere":
				subitem.set_custom_font_size(0,20)
				subitem.set_custom_color(0,"#ffffff")
				subitem.set_selectable(0,false)
				for s in o.get_children():
					var subsubitem = comp_tree.create_item(subitem)
					subsubitem.set_text(0,s.name.capitalize().replace("_"," "))
					create_substance_tree_item(subsubitem,s)
			if "obj_title" in o:
				subitem.set_text(0,o.obj_title)
			else:
				subitem.set_text(0,o.name.capitalize().replace("_"," "))

func create_substance_tree_item(subitem:TreeItem,o:Substance) -> void:
	var rect : Rect2i
	if o is Chemical:
		match o.state:
			Chemical.STATES.SOLID:
				rect = Rect2i(0,0,18,18)
			Chemical.STATES.LIQUID:
				rect = Rect2i(18,0,18,18)
			Chemical.STATES.GAS:
				rect = Rect2i(0,18,18,18)
			Chemical.STATES.PLASMA:
				rect = Rect2i(18,18,18,18)
	elif o is Rock:
		rect = Rect2i(0,0,18,18)
	var tex = AtlasTexture.new()
	tex.atlas = matter_icons
	tex.region = rect
	subitem.set_icon(0,recolor_icon(tex,o.item_color))
	subitem.set_selectable(1,false)
	subitem.set_text(1,str(o.comp_percent*100)+"%")

func _on_comp_tree_item_activated(comp_tree:Tree,obj:GenericObject) -> void:
	var selected = comp_tree.get_selected().get_text(0)
	if obj.has_node("Satellites"):
		for s in obj.get_node("Satellites").get_children():
			if s.obj_title == selected:
				s.camera_focus_object.emit(s)
