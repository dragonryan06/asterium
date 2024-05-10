@icon("res://editor/Reagent.svg")
extends Node
class_name Reagent

const STATE_DESCRIPTORS = ["solid *","liquid *","gaseous *","* plasma","* - unknown state"]
enum STATES {
	SOLID,
	LIQUID,
	GAS,
	PLASMA
}
enum TAGS {
	THALASSOGEN,
	OCEANIC_SOLUTE,
	GREENHOUSE_GAS,
	MINERAL,
	ROCK_FORMING,
	BASE_GAS,
	NOBLE_GAS,
	POISON
}

static func get_state_icon(r:Reagent) -> AtlasTexture:
	var rect: Rect2i
	match r.state:
		Reagent.STATES.SOLID:
			rect = Rect2i(0,0,18,18)
		Reagent.STATES.LIQUID:
			rect = Rect2i(18,0,18,18)
		Reagent.STATES.GAS:
			rect = Rect2i(0,18,18,18)
		Reagent.STATES.PLASMA:
			rect = Rect2i(18,18,18,18)
		_:
			rect = Rect2i(0,0,0,0)
	var tex = AtlasTexture.new()
	if rect.size.x != 0:
		tex.atlas = load("res://ui/assets/matterstate_icons.png")
		tex.region = rect
	else:
		tex.atlas = load("res://ui/assets/question_icon.png")
		tex.region = Rect2i(0,0,16,16)
	return tex

# name of Reagent to autoload
@export var load_initial : String : 
	set(val):
		if val!="":
			construct_from(Constants.get_reagent_data()[val])
			load_initial = val

# The name of this Reagent
var reagent_name : String
# The temperature, in K at which this Reagent state changes between solid/liquid
var melt_point : float
# The temperature, in K at which this Reagent state changes between liquid/gas
var boil_point : float
# The temperature, in K at which this Reagent state changes between gas/plasma
var ionize_point : float
# The density, in kg/m^3 of this Reagent
var density : float
# The specific heat capacity, in kJ/(kg K) of this Reagent
var specific_heat : float
# The color this Reagent is represented by in UI
var ui_color : Color
# The color this Reagent assumes in reality
var color : Color
# The interactions this Reagent has at certain temperatures in the presence of other Reagents.
var reactions : Dictionary
# This Reagent's tags
var tags : Array

# The temperature, in K of this Reagent
var temperature : float = -1 : set=_set_temp
# The state this Reagent is currently in (see STATES)
var state : int = -1
# The amount, in kg, there is of this Reagent
var mass : float = -1

func _set_temp(new) -> void:
	temperature = new
	update_state()

func update_state() -> void:
	if !(get_parent() is Solution and get_parent().stasis):
		state = check_state_change()

func check_state_change() -> int:
	var s = state
	if ionize_point!=-1 and temperature>ionize_point:
		s = STATES.PLASMA
	elif boil_point!=-1 and temperature>boil_point:
		s = STATES.GAS
	elif melt_point!=-1 and temperature>melt_point:
		s = STATES.LIQUID
	elif melt_point!=-1 and temperature<=melt_point:
		s = STATES.SOLID
	return s

# Initialize values from res://gamedata/ json dictionaries
func construct_from(data:Dictionary) -> void:
	reagent_name = data["reagent_name"]
	melt_point = data["melt_point"]
	boil_point = data["boil_point"]
	ionize_point = data["ionize_point"]
	density = data["density"]
	specific_heat = data["specific_heat"]
	ui_color = Color.from_string(data["ui_color"],Color(1.0,0.0,1.0))
	color = Color.from_string(data["color"],Color(1.0,0.0,1.0))
	reactions = data["reactions"]
	var tags = []
	for t in data["tags"]:
		tags.append(TAGS.keys().find(t))
