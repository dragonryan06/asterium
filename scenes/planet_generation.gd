extends Node2D

const _Star = preload("res://core/space/star.tscn")
const _Planet = preload("res://core/space/planet.tscn")

# thoughts:
# perhaps some Curve resources should be saved to skew the probability and allow for some extremely rare edge case things
# because right now its just uniformly distributed and capped at a somewhat reasonable value.
# also like, according to wikipedia, 76% of main-sequence stars are M-class, but these probabilities could be modified to make more interesting stuff

var star_data : Dictionary
var planet_data : Dictionary
var rock_data : Dictionary
var name_data : Dictionary

func _ready() -> void:
	star_data = ResourceManager.load_json("res://gamedata/stars.json").data
	planet_data = ResourceManager.load_json("res://gamedata/planets.json").data
	rock_data = ResourceManager.load_json("res://gamedata/chemistry/rocks.json").data
	name_data = ResourceManager.load_json("res://gamedata/random_names.json").data

func generate_star() -> Star:
	var star = _Star.instantiate()
	var solar_class = star_data["main-sequence"].keys().pick_random()
	var data = {}
	if randi_range(0,1)==0:
		data["obj_name"]=str(randi_range(1,9))+"-"+Constants.ALPHABET.pick_random()+Constants.ALPHABET.pick_random()+"-"+str(randi_range(0,9))+""+str(randi_range(0,9))+""+str(randi_range(0,9))
	else:
		data["obj_name"]=name_data["star"]["prefix"].pick_random()+name_data["star"]["suffix"].pick_random()
	data["obj_class"]=solar_class+"-class Main Sequence Star"
	
	data["mass"]=randf_range(star_data["main-sequence"][solar_class]["mass_min"],star_data["main-sequence"][solar_class]["mass_max"])
	data["radius"]=randf_range(star_data["main-sequence"][solar_class]["radius_min"],star_data["main-sequence"][solar_class]["radius_max"])
	data["orbital_parent"]=null
	data["orbital_period"]=-1
	data["orbital_radius"]=-1
	data["rotational_period"]=randf_range(-5,5)
	
	data["chromaticity"]=star_data["main-sequence"][solar_class]["chromaticity"]
	data["temperature"]=randi_range(star_data["main-sequence"][solar_class]["temp_min"],star_data["main-sequence"][solar_class]["temp_max"])
	
	var composition = Reagent.new()
	composition.name = "CompositionComponent"
	composition.construct_from(Constants.get_reagent_data()["hydrogen"])
	composition.temperature = data["temperature"]
	star.add_child(composition)
	
	star.setup(data)
	return star

func generate_planet(parent_star:Star) -> Planet:
	var planet = _Planet.instantiate()
	var base = planet_data["common"]["barren"]
	var data = {}
	
	data["orbital_parent"] = parent_star
	data["orbital_radius"] = randf_range(0.5,1.0)+parent_star.radius
	data["obj_class"] = base["basic"]["name"]
	data["description"] = base["basic"]["base_sentence"]
	data["radius"] = randf_range(base["basic"]["radius_min"],base["basic"]["radius_max"])
	planet.setup(data)
	
	var surface = Solution.new()
	var rock_type = rock_data[base["geology"]["primary_rock_type"]]
	surface.solution_name = rock_type.keys().pick_random()
	for mineral in rock_type[surface.solution_name]["ratios"]:
		var reagent = Reagent.new()
		reagent.construct_from(Constants.get_reagent_data()[mineral])
		surface.composition.append(rock_type[surface.solution_name]["ratios"][mineral])
		surface.add_child(reagent)
		print(reagent)
	planet.add_child(surface)
	planet.print_tree_pretty()
	
	return planet

#func generate_planet(parent_star:Star) -> CelestialObject:
	### THIS IS JUST FOR TERRESTRIAL
	#var planet = _Planet.instantiate()
	#planet.object_inspector = $HUD/ObjectInspector
	#var data = {}
	#
	#data["radius"] = randf_range(planet_data["planet"]["terrestrial"]["radius_min"],planet_data["planet"]["terrestrial"]["radius_max"])
	#data["mass"] = ((4.0/3.0)*PI*pow(data["radius"],3.0))
	#data["rotational_period"] = randf_range(-5,5)
	#data["orbital_parent"] = parent_star
	#if len(parent_star.get_node("Satellites").get_children())==0:
		#data["orbital_radius"] = randf_range(0.5,1.0)+parent_star.radius
	#else:
		#data["orbital_radius"] = parent_star.get_node("Satellites").get_children()[-1].orbital_radius+randf_range(0.5,1.0)+parent_star.radius
	#
	#var parent_rock = Rock.new()
	## create initial mineral soup
	#parent_rock.mafic_felsic_ratio = randf_range(0.0,1.0)
	## cool magma into igneous rock
	#var cool_time = Rock.cool_times.values().pick_random()
	#var idx = 0
	#var nearest_match = [1.0,-1]
	#for rock in rock_data["igneous"].values():
		#if rock["cooling_time"]==cool_time:
			#if abs(rock["mafic_felsic_ratio"]-parent_rock.mafic_felsic_ratio)<nearest_match[0]:
				#nearest_match[0] = abs(rock["mafic_felsic_ratio"]-parent_rock.mafic_felsic_ratio)
				#nearest_match[1] = idx
		#idx+=1
	#parent_rock.name = rock_data["igneous"].keys()[nearest_match[1]]
	#parent_rock.base_color = Color(rock_data["igneous"][parent_rock.name]["base_color"])+Color(randf_range(-0.005,0.005),randf_range(-0.005,0.005),randf_range(-0.005,0.005))
	#parent_rock.item_color = Color(rock_data["igneous"][parent_rock.name]["base_color"])
	#parent_rock.comp_percent = 1.0
	#planet.get_node("Composition/Surface").add_child(parent_rock)
	#
	## implementing albedo later, for now assuming that all planets are totally matte black
	#var albedo = 0.0
	#data["base_temperature"] = pow((parent_star.luminosity*(1.0-albedo))/(16.0*PI*pow(data["orbital_radius"]*Constants.M_IN_AU,2.0)),0.25)
	## initial ocean/atmosphere
	#var ocean = Chemical.new()
	#var o_mat = Chemical.data["liquid"].keys().pick_random()
	#ocean.from_dictionary(o_mat,Chemical.data["liquid"][o_mat],Chemical.STATES.LIQUID)
	#ocean.comp_percent = 1.0
	#planet.get_node("Composition/Ocean").add_child(ocean)
	#data["ocean_coverage_percent"] = randf_range(0.0,1.0)
	#
	#planet.get_node("Sprite").texture.noise.seed = randi()
	#planet.setup(data)
	#return planet

func generate_system():
	var star = generate_star()
	
	var planet = generate_planet(star)
	#planet.camera_focus_object.connect($Camera2D._on_camera_focus_object)
	var angle = randf_range(0,TAU)
	planet.position = Vector2(planet.orbital_radius*cos(angle)*2048,planet.orbital_radius*sin(angle)*2048)
	planet.obj_name=star.obj_name+" - "+Constants.romanify(1)
	star.get_node("Satellites").add_child(planet)
	
	#for i in range(0,randi_range(3,6)):
		#var planet = generate_planet(star)
		#planet.camera_focus_object.connect($Camera2D._on_camera_focus_object)
		#var angle = randf_range(0,TAU)
		#planet.position = Vector2(planet.orbital_radius*cos(angle)*2048,planet.orbital_radius*sin(angle)*2048)
		#planet.obj_title = star.obj_title+" - "+Constants.romanify(i+1)
		#planet.obj_subtitle = "world type"
		#star.get_node("Satellites").add_child(planet)
	
	#star.camera_focus_object.connect($Camera2D._on_camera_focus_object)
	add_child(star)

func _on_generate_pressed():
	for c in get_children():
		if c.has_node("Sprite"):
			c.queue_free()
			remove_child(c)
			break
	generate_system()
