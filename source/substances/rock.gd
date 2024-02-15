extends Substance
class_name Rock

static var data = ResourceManager.load_json("res://source/globals/rock.json").data

enum states {
	SOLID,
	LAVA,
	SEDIMENT
}
enum cool_times {
	SLOW,
	RAPID,
	INSTANTANEOUS
}

var state = -1
var mafic_felsic_ratio = -1 : set=_set_mafic_felsic_ratio

func _set_mafic_felsic_ratio(val:float) -> void:
	mafic_felsic_ratio = val

#func _set_temperature(new_temp:float) -> void:
	#-temperature-new_temp                  To add dynamically cooled rock, calculate how much it overshot
	#temperature = new_temp

func from_dictionary(_name:String,dict:Dictionary,_state:int) -> void:
	state = _state
	super(_name,dict,_state)
