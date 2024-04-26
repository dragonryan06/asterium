extends DialogPanelContainer

@onready var bold_font = preload("res://fonts/PixelOperator-Bold.ttf")

func setup_data(target:Solution) -> void:
	$VBoxContainer/Title/HBoxContainer/Label.text = target.solution_name
	var largest_component = target.get_largest_component()
	$VBoxContainer/Title/HBoxContainer/AspectRatioContainer/TextureRect.texture = InspectComponent.recolor_icon(Reagent.get_state_icon(largest_component),target.solution_color)
	$VBoxContainer/HFlowContainer/Mass.text = $VBoxContainer/HFlowContainer/Mass.text.replace("MASS",str(snapped(target.mass,0.001))).replace("kg",target.mass_unit)
	$VBoxContainer/HFlowContainer/Temperature.text = $VBoxContainer/HFlowContainer/Temperature.text.replace("TEMP",str(snapped(largest_component.temperature,0.001)))
	var tree = $VBoxContainer/MarginContainer/Contents
	tree.columns = 2
	var root = tree.create_item()
	root.set_text(0,"Contents:")
	root.set_selectable(0,false)
	root.set_custom_font(0,bold_font)
	root.set_tooltip_text(0," ")
	root.set_text(1," %")
	root.set_custom_color(1,Color("#acacac"))
	root.set_selectable(1,false)
	root.set_tooltip_text(0," ")
	
	for r:Reagent in target.get_children():
		var item = tree.create_item(root)
		item.set_icon(0,InspectComponent.recolor_icon(Reagent.get_state_icon(r),r.ui_color))
		item.set_text(0,Reagent.STATE_DESCRIPTORS[r.state].replace("*",r.reagent_name.capitalize()).capitalize())
		item.set_text(1,str(target.composition[r.get_index()]*100))
		item.set_custom_color(1,Color("#acacac"))
		item.set_selectable(1,false)
		item.set_tooltip_text(1," ")
