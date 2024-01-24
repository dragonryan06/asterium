extends Node2D

@export var spectrum : Gradient

const obj_type = "star"

# this value must be set before this object enters the tree to allow inspecting
var inspector : Control

var solar_class : String
var chromaticity : String
var rotational_velocity : float : set=_set_rotvel# */s ---- 360*/d = 0.004*/s
var temperature : int : set=_set_temp            #  K  ---- 5,800K = 1*sun
var radius : float                       # solar radii ---- 1 solar radii = 696,340km
var mass : float                        # solar masses ---- 1 solar mass = 2 quettakilograms

# BUG : rotational_speed is not changing the speed that it scrolls at, just the size of the UV of the surface

func _set_rotvel(val:float):
	rotational_velocity = val
	$Sprite.get_material().set_shader_parameter("rotSpeed",abs(val))
	var dir = val/abs(val)
	$Sprite.get_material().set_shader_parameter("rotDirection",Vector2(dir,0))

func _set_temp(val:int):
	temperature = val
	# cap temperature-color spectrum at 30k so that oranges arent all washed out
	if val>30000:
		val = 30000
	var normVal = (float(val)-2400.0)/(30000.0-2400.0)
	$Sprite.get_material().set_shader_parameter("color",spectrum.sample(normVal))

func _set_radius(val:float):
	radius = val
	$Sprite.scale = Vector2(512,512)*val

var hover = false
var hover_tween : Tween
var show_details = false

func update_details() -> void:
	$CelestialInfoDialog/Control/Title.text = name
	$CelestialInfoDialog/Control/Subtitle.text = solar_class+"-class Main Sequence Star"
	$CelestialInfoDialog/Control/Details.text = "[u]Rotational Period:[/u] xyzabc\n[u]Chromaticity:[/u] "+chromaticity+"\n[u]Surface Temperature:[/u] "+str(temperature)+" K\n[u]Radius:[/u] "+str(round(radius*pow(10,3))/pow(10,3))+" R*\n[u]Mass:[/u] "+str(round(mass*pow(10,3))/pow(10,3))+" M*"
	$CelestialInfoDialog/Control/Description.text = "\t"+name+" is a large sphere composed of plasma. It is constantly fusing atoms together, converting a fraction of their mass into energy each time. \n\tIt is the heart of the \n"+name+" system, and provides the "+chromaticity+" illumination seen in its satellites' skies"

func _draw():
	var radius = $Sprite.scale[0]/4.0
	if hover or show_details:
		draw_arc(position,radius,0,TAU,75,Color("#cccccc"),6,true)
	if show_details:
		draw_line(Vector2(position.x+radius,position.y), Vector2(position.x+radius*2.5,position.y),Color("#cccccc"),6,true)
		$CelestialInfoDialog.position = Vector2(position.x+radius*2.5,position.y)

func _input(event):
	if hover and event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if not show_details:
			show_details = true
			hover_tween.kill()
			update_details()
			$CelestialInfoDialog.show()
			self_modulate.a = 1
			queue_redraw()
		else:
			show_details = false
			$CelestialInfoDialog.hide()
			_on_hitbox_mouse_entered()

func _on_hitbox_mouse_entered():
	hover = true
	queue_redraw()
	if not show_details:
		hover_tween = get_tree().create_tween()
		hover_tween.tween_property(self,"self_modulate",Color(1,1,1,1),0.5).from(Color(1,1,1,0.25)).set_trans(Tween.TRANS_SINE)
		hover_tween.tween_property(self,"self_modulate",Color(1,1,1,0.25),0.5).from(Color(1,1,1,1)).set_trans(Tween.TRANS_SINE)
		hover_tween.set_loops(-1)

func _on_hitbox_mouse_exited():
	hover_tween.kill()
	hover = false
	queue_redraw()
