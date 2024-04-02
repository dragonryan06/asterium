extends Node
class_name Solution

# The name of this Solution (assumes largest reagent's name if solution has no other name)
var solution_name
# The total mass of this Solution
var mass : float
# The percentages (0.0 -> 1.0) that each child Reagent makes up of the whole mass
var composition : Array
# Whether this solution is homogenous or heterogenous
var homogenous : bool

func _on_child_order_changed():
	pass # Replace with function body.
