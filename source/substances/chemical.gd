extends Substance
class_name Chemical

static var data = ResourceManager.load_json("res://source/globals/chemical.json").data

enum states {
	SOLID,
	LIQUID,
	GAS,
	PLASMA
}

var state = -1
var c_state = [-1,null]
var e_state = [-1,null]

func _set_temperature(new_temp) -> void:
	temperature = new_temp
	while e_state[0]!=-1 and temperature>e_state[0]:
		state+=1
		c_state[0] = e_state[0]; c_state[1] = name
		name = e_state[1]
		e_state[0] = data.values()[state][name]["expand_temp"]; e_state[1] = data.values()[state][name]["expand_state"]
		state_changed.emit()
	while c_state[0]!=-1 and temperature<c_state[0]:
		state-=1
		e_state[0] = c_state[0]; e_state[1] = name
		name = c_state[1]
		c_state[0] = data.values()[state][name]["condense_temp"]; c_state[1] = data.values()[state][name]["condense_state"]
		state_changed.emit()

func from_dictionary(_name:String,dict:Dictionary,_state:int) -> void:
	state = _state
	c_state[0] = dict["condense_temp"]; c_state[1] = dict["condense_state"]
	e_state[0] = dict["expand_temp"]; e_state[1] = dict["expand_state"]
	super(_name,dict,_state)
