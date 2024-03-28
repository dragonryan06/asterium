extends Node

static func generate_terrestrial_description(planet:TerrestrialPlanet) -> String:
	return ""

static func _color_item_text(substance:Substance) -> String:
	return "[u][color="+substance.item_color.to_html(false)+"]"+substance.name+"[/color][/u]"
