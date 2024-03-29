extends Node

enum STATES {
	SOLID,
	LIQUID,
	GAS,
	PLASMA
}
enum TAGS {
	OCEANIC_SOLVENT,
	OCEANIC_SOLUTE,
	GREENHOUSE_GAS,
	MINERAL
}

# The name of this Reagent
var reagent_name : String
# The temperature at which this Reagent state changes between solid/liquid
var melt_point : float
# The temperature at which this Reagent state changes between liquid/gas
var boil_point : float
# The temperature at which this Reagent state changes between gas/plasma
var ionize_point : float
# The density, in kg/m^3 of this Reagent
var density : float
# The specific heat capacity, in J/(kg K) of this Reagent
var specific_heat : float
# The color this Reagent is represented by in UI
var ui_color : Color
# The color this Reagent assumes in reality
var color : Color

# The temperature, in K of this Reagent
var temperature : float
# The state this Reagent is currently in (see STATES)
var state : int
# The amount, in kg, there is of this Reagent
var mass : float
# The interactions this Reagent has at certain temperatures in the presence of other Reagents.
var reactions : Array

# Initialize values from res://gamedata/ json dictionaries
func construct_from(data:Dictionary) -> void:
	pass
