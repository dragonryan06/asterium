extends Substance
class_name Chemical

static var data = ResourceManager.load_json("res://gamedata/chemicals.json").data

enum STATES {
	SOLID,
	LIQUID,
	GAS,
	PLASMA
}

var state = -1
var c_state = null
var c_temp = -1
var e_state = null
var e_temp = -1

func _set_temperature(new_temp) -> void:
	temperature = new_temp
	while e_temp!=-1 and temperature>e_temp:
		state+=1
		c_temp = e_temp; c_state = name
		name = e_state
		e_temp = data.values()[state][name]["expand_temp"]; e_state = data.values()[state][name]["expand_state"]
		state_changed.emit()
	while c_temp!=-1 and temperature<c_temp:
		state-=1
		e_temp = c_temp; e_state = name
		name = c_state
		c_temp = data.values()[state][name]["condense_temp"]; c_state = data.values()[state][name]["condense_state"]
		state_changed.emit()

func from_dictionary(_name:String,dict:Dictionary,_state:int) -> void:
	state = _state
	c_temp = dict["condense_temp"]; c_state = dict["condense_state"]
	e_temp = dict["expand_temp"]; e_state = dict["expand_state"]
	super(_name,dict,_state)
