extends Node
class_name Substance

signal state_changed

## The visible color this Substance draws as
var base_color : String
## The color this Substance is represented by
var item_color : String
var temperature : float : set=_set_temperature

func from_dictionary(_name:String,dict:Dictionary,_state:int) -> void:
	base_color = dict["base_color"]
	item_color = dict["item_color"]
	name = _name

func _set_temperature(new_temp) -> void:
	temperature = new_temp
