extends Node2D

const _Star = preload("res://source/objects/celestial/star.tscn")
const _Planet = preload("res://source/objects/celestial/planet.tscn")
const alphabet = ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"]

# thoughts:
# perhaps some Curve resources should be saved to skew the probability and allow for some extremely rare edge case things
# because right now its just uniformly distributed and capped at a somewhat reasonable value.
# also like, according to wikipedia, 76% of main-sequence stars are M-class, but these probabilities could be modified to make more interesting stuff

var star_data : Dictionary
var rock_data : Dictionary

func _ready():
	star_data = ResourceManager.load_json("res://source/globals/star.json").data
	rock_data = ResourceManager.load_json("res://source/globals/rock.json").data

func generate_star() -> void:
	var star = _Star.instantiate()
	star.object_inspector = $HUD/ObjectInspector
	var solar_class = star_data["main-sequence"].keys().pick_random()
	var data = {}
	data["obj_title"]=str(randi_range(1,9))+"-"+alphabet.pick_random()+alphabet.pick_random()+"-"+str(randi_range(0,9))+""+str(randi_range(0,9))+""+str(randi_range(0,9))
	data["obj_subtitle"]=solar_class+"-class Main Sequence Star"
	
	data["mass"]=randf_range(star_data["main-sequence"][solar_class]["mass_min"],star_data["main-sequence"][solar_class]["mass_max"])
	data["radius"]=randf_range(star_data["main-sequence"][solar_class]["radius_min"],star_data["main-sequence"][solar_class]["radius_max"])
	data["orbital_parent"]=null
	data["orbital_period"]=-1
	data["rotational_period"]=86400 #idk, come up with some numbers for this
	
	data["chromaticity"]=star_data["main-sequence"][solar_class]["chromaticity"]
	data["temperature"]=randi_range(star_data["main-sequence"][solar_class]["temp_min"],star_data["main-sequence"][solar_class]["temp_max"])
	
	star.setup(data)
	add_child(star)

func generate_planet() -> void:
	var planet = _Planet.instantiate()
	planet.object_inspector = $HUD/ObjectInspector
	var data = {}
	var parent_rock
	# create initial mineral soup
	var mineral_content = {
		"feldspar-index":randf_range(0.0,1.0)
	}
	# cool magma into igneous rock
	var cool_time = ["slow","rapid"].pick_random()
	var idx = 0
	var nearest_match = [1.0,-1]
	for rock in rock_data["igneous"].values():
		if rock["cooling-time"]==cool_time:
			if abs(rock["feldspar-index"]-mineral_content["feldspar-index"])<nearest_match[0]:
				nearest_match[0] = abs(rock["feldspar-index"]-mineral_content["feldspar-index"])
				nearest_match[1] = idx
		idx+=1
	parent_rock = rock_data["igneous"].keys()[nearest_match[1]]
	print(mineral_content," ",cool_time)
	print(parent_rock)
	data["parent_rock"] = {"name":parent_rock,"color":Color(rock_data["igneous"][parent_rock]["base-color"])+Color(randf_range(-0.005,0.005),randf_range(-0.005,0.005),randf_range(-0.005,0.005))}
	
	planet.setup(data)
	add_child(planet)

func _on_generate_pressed():
	for c in get_children():
		if c.has_node("Sprite"):
			c.queue_free()
			remove_child(c)
			break
	#generate_star()
	generate_planet()

