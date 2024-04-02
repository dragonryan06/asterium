extends CelestialObject
class_name Star

## Cold-hot color gradient to use
@export var spectrum : Gradient

## This Star's vega-relative chromaticity (based on class)
var chromaticity : String
## This Star's surface temperature, in K
var temperature : int : set=_set_temperature
## This Star's luminosity (divided by the stefan-boltzmann constant), determined from temperature
var luminosity : float

func _set_radius(val:float) -> void:
	radius = val
	$Sprite.texture.noise.seed = randi()
	$Sprite.get_material().get_shader_parameter("corona_texture").noise.seed = randi()
	$Sprite.texture.width = 128*radius
	$Sprite.texture.height = 64*radius
	$Sprite/Hitbox.scale = Vector2(128*radius,64*radius)
	$Sprite.get_material().get_shader_parameter("corona_texture").width = 64*radius
	$Sprite.get_material().get_shader_parameter("corona_texture").height = 64*radius
	$Sprite.get_material().get_shader_parameter("corona_texture").noise.frequency = 0.05/radius
func _set_temperature(val:int) -> void:
	temperature = val
	# cap temperature-color spectrum at 30k so that oranges arent all washed out
	if val>30000:
		val = 30000
	var normVal = (float(val)-2400.0)/(30000.0-2400.0)
	$Sprite.get_material().set_shader_parameter("base_color",spectrum.sample(normVal))
	$Sprite/PointLight2D.color = spectrum.sample(normVal)
	# formula from https://www.astronomy.ohio-state.edu/thompson.1847/1144/Lecture9.html
	# because this value is internal and used only for temperature where the stefan-boltzmann constant is divided back out, it is being divided out in advance.
	luminosity = 4.0*PI*pow(radius*Constants.M_IN_SR,2.0)*pow(temperature,4.0)

func setup(data:Dictionary) -> void:
	# make unique material and texture
	$Sprite.texture = $Sprite.texture.duplicate()
	$Sprite.material = $Sprite.material.duplicate()
	for k in data.keys():
		set(k,data[k])

func _ready():
	$InspectComponent.tt_title_text = obj_title
	$InspectComponent.tt_subtitle_text = obj_subtitle

func _draw() -> void:
	for p in $Satellites.get_children():
		draw_arc(position,p.orbital_radius*2048,0,TAU,128,Color("white"))
