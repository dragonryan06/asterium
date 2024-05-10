extends CelestialObject
class_name Planet

enum TAGS {
	# ocean has completely vaporized from base_temperature
	BOILED_OCEAN,
	# ocean has completely frozen from base_temperature
	FROZEN_OCEAN
}

#var chemical_data = ResourceManager.load_json("res://gamedata/chemicals.json").data

var temperature : float
var ocean_coverage_percent : float : set=_set_ocean_coverage_percent

# currently just for description
var weather : String
var magfield : String
var atm_desc : String

#func _ready():
	#$Sprite.get_material().set_shader_parameter("base_color",$Composition/Surface.get_child(0).base_color)
	#for layer in $Composition.get_children():
		#for substance in layer.get_children():
			#if not substance.state_changed.is_connected(_on_state_change):
				#substance.state_changed.connect(_on_state_change.bind(substance))
			#substance.temperature = base_temperature

func _set_ocean_coverage_percent(surface_coverage) -> void:
	ocean_coverage_percent = surface_coverage
	var color = Color(1.0,0.0,1.0,1.0)
	if ocean_coverage_percent!=0:
		color = $Composition/Ocean.get_child(0).base_color
	if color.a == 0:
		color = Color(0.5,0.5,0.5,1.0)
	$Sprite.get_material().set_shader_parameter("ocean_color",Color(color))
	$Sprite.get_material().set_shader_parameter("ocean_coverage",ocean_coverage_percent)

func setup(data:Dictionary) -> void:
	# make unique material and texture
	$Sprite.texture = $Sprite.texture.duplicate()
	$Sprite.material = $Sprite.material.duplicate()
	for k in data.keys():
		set(k,data[k])

#func _on_state_change(substance:Substance) -> void:
	#if substance is Chemical:
		#if $Composition/Ocean.is_ancestor_of(substance):
			#if substance.state==Chemical.STATES.SOLID:
				#tags.append(TAGS.FROZEN_OCEAN)
			#elif substance.state==Chemical.STATES.GAS:
				#tags.append(TAGS.BOILED_OCEAN)
				#$Composition/Ocean.remove_child(substance)
				#$Composition/Atmosphere.add_child(substance)
				#ocean_coverage_percent = 0.0

#func _on_composition_child_order_changed() -> void:
	## determine if this is a tree exit or just a change, if just a change, update shaders/signals.
	#if find_child("Composition"):
		#$Sprite.get_material().set_shader_parameter("base_color",$Composition/Surface.get_child(0).base_color)
		#for layer in $Composition.get_children():
			#for substance in layer.get_children():
				#if not substance.state_changed.is_connected(_on_state_change):
					#substance.state_changed.connect(_on_state_change.bind(substance))
