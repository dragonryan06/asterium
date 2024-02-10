extends CelestialObject
class_name TerrestrialPlanet

var chemical_data = ResourceManager.load_json("res://source/globals/chemical.json").data

## The temperature of this world from solar radiation
var base_temperature : float 
## The primary rock this world is made of
var parent_rock : Dictionary : set=_set_parent_rock
## The other minerals found within the rock in the form of ores (mineral_richness 100% means there is no parent rock)
var mineral_composition : Dictionary
var mineral_richness : float
## Primary gases in atmosphere
var gas_composition : Dictionary
var gas_density : float
## Primary liquids/ice sheets on the surface
var liquid_composition : Chemical
var liquid_surface_coverage : float : set=_set_liquid_surface_coverage

func _set_parent_rock(rocktype:Dictionary) -> void:
	parent_rock = rocktype
	$Sprite.get_material().set_shader_parameter("base_color",rocktype["color"])

func _set_liquid_surface_coverage(surface_coverage) -> void:
	liquid_surface_coverage = surface_coverage
	var color = liquid_composition.base_color
	if color == "clear":
		return
	$Sprite.get_material().set_shader_parameter("ocean_color",Color(color))
	$Sprite.get_material().set_shader_parameter("ocean_coverage",liquid_surface_coverage)

func setup(data:Dictionary) -> void:
	# make unique material and texture
	$Sprite.texture = $Sprite.texture.duplicate()
	$Sprite.material = $Sprite.material.duplicate()
	for k in data.keys():
		set(k,data[k])
