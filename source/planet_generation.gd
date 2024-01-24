extends Node2D

const Star = preload("res://source/celestial/star.tscn")
const alphabet = ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"]

# thoughts:
# perhaps some Curve resources should be saved to skew the probability and allow for some extremely rare edge case things
# because right now its just uniformly distributed and capped at a somewhat reasonable value.
# also like, according to wikipedia, 76% of main-sequence stars are M-class, but these probabilities could be modified to make more interesting stuff

var star_data : Dictionary

func _ready():
	star_data = ResourceManager.load_json("res://source/globals/star.json").data

func _on_generate_pressed():
	for c in get_children():
		if c.has_node("Sprite"):
			c.queue_free()
			remove_child(c)
			break
	var star = Star.instantiate()
	star.name = str(randi_range(1,9))+"-"+alphabet.pick_random()+alphabet.pick_random()+"-"+str(randi_range(0,9))+""+str(randi_range(0,9))+""+str(randi_range(0,9))
	star.solar_class = star_data["main-sequence"].keys().pick_random()
	star.chromaticity = star_data["main-sequence"][star.solar_class]["chromaticity"]
	star.rotational_velocity = randf_range(-5,5) #idk, come up with some numbers for this
	star.temperature = randi_range(star_data["main-sequence"][star.solar_class]["temp_min"],star_data["main-sequence"][star.solar_class]["temp_max"])
	star.radius = randf_range(star_data["main-sequence"][star.solar_class]["radius_min"],star_data["main-sequence"][star.solar_class]["radius_max"])
	star.mass = randf_range(star_data["main-sequence"][star.solar_class]["mass_min"],star_data["main-sequence"][star.solar_class]["mass_max"])
	print("-----------------------")
	print(star.name)
	print(star.solar_class,"-class main-sequence star")
	print(star.temperature," K")
	print(star.radius," solar radii")
	print(star.mass," solar masses")
	add_child(star)
