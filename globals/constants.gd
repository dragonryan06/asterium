@icon("res://editor/Global.svg")
extends Node
class_name Constants

const version = "Asterium alpha pre-v0.0.0"

const M_IN_AU = 149000000000
const M_IN_SR = 696000000
const ALPHABET = ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"]
const ROMAN_NUMERALS = {1000:"M",900:"CM",500:"D",400:"CD",100:"C",90:"XC",50:"L",40:"XL",10:"X",9:"IX",5:"V",4:"IV",1:"I"}

static func romanify(number:int) -> String:
	var roman = ""
	for val in ROMAN_NUMERALS.keys():
		while number-val>=0:
			number-=val
			roman+=ROMAN_NUMERALS[val]
	return roman

static func get_reagent_data() -> Dictionary:
	return ResourceManager.load_json("res://gamedata/chemistry/reagents.json").data

static func pick_random(table:Dictionary):
	var point = randf()
	var cursor = 0.0
	for i in range(len(table.values())):
		cursor+=table.values()[i]
		if cursor >= point:
			return table.keys()[i]
	return "func pick_random() on constants.gd recieved confusing data!"
