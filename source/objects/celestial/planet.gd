extends CelestialObject
class_name Planet

# the primary rock this world is made of (yes, entirely uniform of one material lol oversimplification)
var parent_rock : Dictionary : set=_set_parent_rock
# the other minerals found within the rock in the form of ores
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
	for k in data.keys():
		set(k,data[k])
