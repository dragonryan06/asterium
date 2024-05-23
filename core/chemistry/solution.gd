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
# If this Solution is in stasis, it will not check for state changes or reactions automatically
@export var stasis : bool

func _ready():
	if solution_name=="":
		solution_name = get_largest_component().reagent_name.capitalize().replace("_"," ")+" solution"
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

func get_true_color() -> Color:
	var color = Color.TRANSPARENT
	for r:Reagent in get_children():
		if color == Color.TRANSPARENT:
			color = r.color
		else:
			color = color.lerp(r.color,composition[composition.find(r.reagent_name)])
	if color.a!=0.0:
		color.a=1.0
	return color

func fix_percents() -> void:
	# force composition to add to 1.0
	var sum = 0.0
	for i in composition:
		sum+=i
	if sum!=1.0:
		for i in range(len(composition)):
			composition[i]+=(1.0-sum)/float(len(composition))

func add(what:Reagent,amt:float,as_percent:bool) -> void:
	if as_percent:
		var reagents = []
		for r in get_children():
			reagents.append(r.reagent_name)
		if what.reagent_name in reagents:
			composition[reagents.find(what.reagent_name)]+=amt
		else:
			add_child(what)
			composition.append(amt)
	# TODO: otherwise, amt is assumed to be in the mass units of the solution
