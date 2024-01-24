extends CelestialObject

## Cold-hot color gradient to use
@export var spectrum : Gradient

## This Star's vega-relative chromaticity (based on class)
var chromaticity : String
## This Star's surface temperature, in K
var temperature : int : set=_set_temperature

func _set_temperature(val:int) -> void:
	temperature = val
	# cap temperature-color spectrum at 30k so that oranges arent all washed out
	if val>30000:
		val = 30000
	var normVal = (float(val)-2400.0)/(30000.0-2400.0)
	$Sprite.get_material().set_shader_parameter("color",spectrum.sample(normVal))

func setup(data:Dictionary) -> void:
	for k in data.keys():
		set(k,data[k])

var hover = false

func _show_tooltip():
	if hover:
		object_inspector.show_tooltip(self)

func _on_hitbox_mouse_entered() -> void:
	hover = true
	var timer = get_tree().create_timer(0.5)
	timer.timeout.connect(_show_tooltip)

func _on_hitbox_mouse_exited() -> void:
	hover = false
	object_inspector.hide_tooltip()
