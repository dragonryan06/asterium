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

var ocean_coverage : float : set=_set_ocean_coverage

func _set_parent_rock(rocktype:Dictionary) -> void:
	parent_rock = rocktype
	$Sprite.get_material().set_shader_parameter("base_color",rocktype["color"])

func _set_ocean_coverage(surface_coverage) -> void:
	ocean_coverage = surface_coverage
	var color = $Composition/Ocean.get_child(0).base_color
	if color == "clear":
		color = Color(0.5,0.5,0.5,1.0)
	$Sprite.get_material().set_shader_parameter("ocean_color",Color(color))
	$Sprite.get_material().set_shader_parameter("ocean_coverage",ocean_coverage)

func setup(data:Dictionary) -> void:
	# make unique material and texture
	$Sprite.texture = $Sprite.texture.duplicate()
	$Sprite.material = $Sprite.material.duplicate()
	for k in data.keys():
		set(k,data[k])
