extends Control

const formats = {
	"star": {
		"details":"[u]Rotational Period:[/u] {rotational_period} d\n[u]Chromaticity:[/u] {chromaticity}\n[u]Surface Temperature:[/u] {temperature} K\n[u]Radius:[/u] {radius} R*\n[u]Mass:[/u] {mass} M*",
		"description":"\t{obj_title} is a large sphere composed of plasma. It is constantly fusing atoms together, converting a fraction of their mass into energy each time. \n\tIt is the heart of the {obj_title} system, and provides the {chromaticity} illumination seen in its satellites' skies"
	},
	"terrestrial_planet": {
		"details":"[u]Rotational Period:[/u] {rotational_period} d\n[u]Parent Rock:[/u] {parent_rock.name}\n[u]Temperature:[/u] {base_temperature} K\n[u]Ocean:[/u] {liquid_composition.solvent}\n[u]Ocean Coverage:[/u] {liquid_surface_coverage}",
		"description":"\t{obj_title} is a planet"
	}
}

var inspecting = false
var dragging = false

func show_inspect(obj:GenericObject) -> void:
	if $Tooltip.modulate.a==1:
		hide_tooltip()
	if obj is CelestialObject:
		$InspectCelestial.position = Vector2(obj.get_global_transform_with_canvas().origin.x+$InspectCelestial.size.x,obj.get_global_transform_with_canvas().origin.y-0.5*$InspectCelestial.size.y)
		$InspectCelestial/Title.text = obj.obj_title
		$InspectCelestial/Subtitle.text = obj.obj_subtitle
		
		var format = ""
		if obj is Star:
			format = "star"
		if obj is TerrestrialPlanet:
			format = "terrestrial_planet"
			
		var details = formats[format]["details"]
		while details.find("{")!=-1:
			var lookup = details.substr(details.find("{")+1,details.find("}")-1-details.find("{"))
			var val
			if lookup.find(".")==-1:
				val = obj.get(lookup)
			else:
				val = obj.get(lookup.split(".")[0]).get(lookup.split(".")[1])
			if val is float:
				val = snapped(val,0.001)
			if val is String:
				val = val.capitalize()
			details = details.substr(0,details.find("{"))+str(val)+details.substr(details.find("}")+1,-1)
		$InspectCelestial/Details.text = details
		var description = formats[format]["description"]
		while description.find("{")!=-1:
			description = description.substr(0,description.find("{"))+str(obj.get(description.substr(description.find("{")+1,description.find("}")-1-description.find("{"))))+description.substr(description.find("}")+1,-1)
		$InspectCelestial/Description.text = description
		var tween = get_tree().create_tween().set_parallel()
		tween.tween_property($InspectCelestial,"modulate",Color(1,1,1,1),0.25)

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
