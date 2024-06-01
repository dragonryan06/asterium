extends CelestialObject
class_name Planet

## might wanna remove these
enum TAGS {
	# ocean has completely vaporized from base_temperature
	BOILED_OCEAN,
	# ocean has completely frozen from base_temperature
	FROZEN_OCEAN
}

var temperature : float
var ocean_coverage_percent : float : set=_set_ocean_coverage_percent

# currently just for description
var weather : String
var magfield : String
var atm_desc : String

func _set_ocean_coverage_percent(surface_coverage) -> void:
	ocean_coverage_percent = surface_coverage
	get_node("Sprite/Ocean").get_material().set_shader_parameter("ocean_surface_coverage",surface_coverage)

func setup(data:Dictionary) -> void:
	# make unique material and texture
	$Sprite.texture = $Sprite.texture.duplicate()
	$Sprite.material = $Sprite.material.duplicate()
	$Sprite/Ocean.texture = $Sprite/Ocean.texture.duplicate()
	$Sprite/Ocean.material = $Sprite/Ocean.material.duplicate()
	$Sprite/Atmosphere.texture = $Sprite/Atmosphere.texture.duplicate()
	$Sprite/Atmosphere.material = $Sprite/Atmosphere.material.duplicate()
	
	for k in data.keys():
		set(k,data[k])
	
	$InspectComponent.trigger_area = $Sprite/Hitbox
	# cant set title here as obj_name is not yet known
	$InspectComponent.tt_subtitle_text = obj_class

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
