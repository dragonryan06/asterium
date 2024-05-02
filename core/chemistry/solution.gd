@icon("res://editor/Solution.svg")
extends Node
class_name Solution

# The name of this Solution (assumes largest reagent's name if solution has no other name)
@export var solution_name : String
# The ui color of this Solution (assumes largest reagent's color if none)
@export var solution_color : Color = Color(0.0,0.0,0.0,0.0)
# The total mass of this Solution
@export var mass : float
@export var mass_unit : String
# The percentages (0.0 -> 1.0) that each child Reagent makes up of the whole mass
@export var composition : Array
# If this Solution is homogenous, it's largest Reagent is a solvent, and all others are solute. Otherwise, it is just a mix.
@export var homogenous : bool

func _ready():
	if solution_name=="":
		solution_name = get_largest_component().reagent_name.replace("_"," ").capitalize()+" Solution"
	if solution_color==Color(0.0,0.0,0.0,0.0):
		solution_color = get_largest_component().ui_color

func set_temperature(new:float) -> void:
	# implement specific heat insulation stuff here
	for c in get_children():
		c.temperature = new

func get_largest_component() -> Reagent:
	# this will error out if you forget to set composition! :)
	var sorted = composition.duplicate()
	sorted.sort()
	return get_child(composition.find(sorted[-1]))
