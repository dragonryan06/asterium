extends CelestialObject
class_name TerrestrialPlanet

# the primary rock this world is made of (yes, entirely uniform of one material lol oversimplification)
var parent_rock : Dictionary : set=_set_parent_rock
# the other minerals found within the rock in the form of ores (mineral_richness 100% means there is no parent rock)
var mineral_composition : Dictionary
var mineral_richness : float
# primary gases in atmosphere
var gas_composition : Dictionary
var gas_density : float
# primary liquids on the surface
var liquid_composition : Dictionary
var liquid_height : float

func _set_parent_rock(rocktype:Dictionary) -> void:
	parent_rock = rocktype
	$Sprite.get_material().set_shader_parameter("base_color",rocktype["color"])

func setup(data:Dictionary) -> void:
	# make unique material and texture
	$Sprite.texture = $Sprite.texture.duplicate()
	$Sprite.material = $Sprite.material.duplicate()
	for k in data.keys():
		set(k,data[k])