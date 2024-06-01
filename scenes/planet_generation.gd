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
var reagent_data : Dictionary

func _ready() -> void:
	star_data = ResourceManager.load_json("res://gamedata/stars.json").data
	planet_data = ResourceManager.load_json("res://gamedata/planets.json").data
	rock_data = ResourceManager.load_json("res://gamedata/chemistry/rocks.json").data
	name_data = ResourceManager.load_json("res://gamedata/random_names.json").data
	reagent_data = Constants.get_reagent_data()

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
	composition.construct_from(reagent_data["hydrogen"])
	composition.temperature = data["temperature"]
	star.add_child(composition)
	
	star.setup(data)
	return star

func generate_planet(parent_star:Star) -> Planet:
	var planet = _Planet.instantiate()
	var base = planet_data["common"][planet_data["common"].keys().pick_random()]
	var data = {}
	
	# basic
	data["orbital_parent"] = parent_star
	if parent_star.get_node("Satellites").get_child_count()==0:
		data["orbital_radius"] = randf_range(0.5,1.0)+parent_star.radius
	else:
		data["orbital_radius"] = randf_range(0.5,1.0)+parent_star.get_node("Satellites").get_child(-1).orbital_radius
	data["obj_class"] = base["basic"]["name"]
	data["description"] = base["basic"]["base_sentence"]
	data["radius"] = randf_range(base["basic"]["radius_min"],base["basic"]["radius_max"])
	data["rotational_period"] = randf_range(-5,5)
	
	# temperature
	var albedo = 0.0
	data["temperature"] = pow((parent_star.luminosity*(1.0-albedo))/(16.0*PI*pow(data["orbital_radius"]*Constants.M_IN_AU,2.0)),0.25)
	
	# geology
	var surface = Solution.new()
	surface.name = "Bedrock"
	var rock_type = rock_data[base["geology"]["primary_rock_type"]]
	surface.solution_name = rock_type.keys().pick_random().capitalize()
	for mineral in rock_type[surface.solution_name.replace(" ","_").to_lower()]["ratios"]:
		var reagent = Reagent.new()
		reagent.construct_from(reagent_data[mineral])
		surface.composition.append(rock_type[surface.solution_name.replace(" ","_").to_lower()]["ratios"][mineral])
		surface.add_child(reagent)
	surface.solution_color = rock_type[surface.solution_name.replace(" ","_").to_lower()]["base_color"]
	surface.set_temperature(data["temperature"])
	planet.add_child(surface)
	
	# ocean
	if base["systems"]["ocean_coverage_max"]>0.0:
		var ocean = Solution.new()
		ocean.name = "Ocean"
		ocean.homogenous = true
		ocean.stasis = true
		# might change later, keep rerolling for a thalassogenic reagent liquid within +-50 K of planetary temp
		var thalassogens = []
		for t in reagent_data.values():
			if t["tags"].has("THALASSOGEN"):
				thalassogens.append(t)
		
		var fail = false
		var i = 0
		while i!=32: # surely after 32 tries theres no way to get a success like ever
			var option = thalassogens.pick_random()
			if abs(option["melt_point"]-data["temperature"])<50.0 or abs(option["boil_point"]-data["temperature"])<50.0 or (data["temperature"]<option["boil_point"] and data["temperature"]>option["melt_point"]):
				var r = Reagent.new()
				r.state = Reagent.STATES.LIQUID
				r.construct_from(option)
				ocean.add(r,1.0,true)
				break
			elif i==31:
				fail = true
				break
			i+=1
		if !fail:
			ocean.set_temperature(data["temperature"])
			planet.ocean_coverage_percent = randf_range(base["systems"]["ocean_coverage_min"],base["systems"]["ocean_coverage_max"])
			planet.add_child(ocean)
		else:
			ocean.queue_free()
			data["obj_class"] = "Dessicated world"
		
	# atmosphere
	var atm = Constants.pick_random(base["systems"]["atmosphere_type_table"])
	data["atm_desc"] = atm
	if atm!="none":
		var atmosphere = Solution.new()
		atmosphere.name = "Atmosphere"
		atmosphere.homogenous = true
		atmosphere.stasis = true
		# might change this later, for now just make 3 rolls for primary components
		const arbitrary_roll_count = 3
		var total_comp = 0
		for i in range(arbitrary_roll_count):
			var r = Reagent.new()
			r.state = Reagent.STATES.GAS
			var tag = Constants.pick_random(base["systems"]["atmosphere_content_table"])
			var list = []
			for t in reagent_data.values():
				if t["tags"].has(tag):
					list.append(t)
			r.construct_from(list.pick_random())
			if i!=arbitrary_roll_count-1:
				var rand = randi_range(0,100-total_comp)
				atmosphere.add(r,float(rand)/100.0,true)
				total_comp+=rand
			else:
				atmosphere.add(r,float(100-total_comp)/100.0,true)
		atmosphere.set_temperature(data["temperature"])
		planet.add_child(atmosphere)
		var precip = Solution.new()
		precip.name = "Precipitation"
		precip.homogenous = true
		precip.stasis = true
		for r in atmosphere.get_children():
			if not (r.check_state_change()==Reagent.STATES.LIQUID or r.check_state_change()==Reagent.STATES.GAS):
				var new_r = r.duplicate()
				new_r.construct_from(reagent_data[r.reagent_name])
				new_r.temperature = r.temperature
				new_r.update_state()
				precip.add(new_r,atmosphere.composition[r.get_index()],true)
		if precip.get_child_count()!=0:
			precip.fix_percents()
			var precip_name = "ERROR"
			match precip.get_largest_component().state:
				Reagent.STATES.LIQUID:
					precip_name = " rain"
				Reagent.STATES.SOLID:
					precip_name = " snow"
			var n = precip.get_largest_component().reagent_name.replace("_"," ")
			precip.solution_name = n.substr(0,1).capitalize()+n.substr(1)+precip_name
			planet.add_child(precip)
	
	# weather, other flavor
	var magfield = Constants.pick_random(base["geology"]["magnetic_field_table"])
	data["magfield"] = magfield
	var weather = Constants.pick_random(base["systems"]["weather_type_table"])
	data["weather"] = weather
	
	# descriptions
	
	# graphics
	var heightmap = FastNoiseLite.new()
	heightmap.seed = randi()
	heightmap.offset = Vector3(-128,-32,0)
	
	var terrain = heightmap.get_seamless_image(256,64,false,false,0.25)
	terrain.convert(Image.FORMAT_RGBA8)
	
	var clouds = FastNoiseLite.new()
	clouds.noise_type = FastNoiseLite.TYPE_CELLULAR
	clouds.seed = randi()
	clouds.frequency = 0.015
	var atmos = clouds.get_seamless_image(256,64)
	
	var rand_atm_tint = func() -> Color:
		return Color(0.5*randf()+0.4,0.5*randf()+0.4,0.5*randf()+0.4,1.0)
	var rand_ocn_tint = func() -> Color:
		return Color(0.5*randf()+0.1,0.5*randf()+0.1,0.5*randf()+0.1,1.0)
	
	planet.get_node("Sprite").texture = ImageTexture.create_from_image(terrain)
	planet.get_node("Sprite/Ocean").texture = planet.get_node("Sprite").texture
	planet.get_node("Sprite/Atmosphere").texture = ImageTexture.create_from_image(atmos)
	
	planet.setup(data)
	if planet.has_node("Atmosphere"):
		planet.get_node("Sprite/Atmosphere").get_material().set_shader_parameter("base_color",planet.get_node("Atmosphere").get_true_color()-Color(0.25,0.25,0.25,1.0)*rand_atm_tint.call())
	if planet.has_node("Ocean"):
		if planet.get_node("Ocean").get_true_color()==Color.TRANSPARENT:
			planet.get_node("Sprite/Ocean").get_material().set_shader_parameter("base_color",rand_ocn_tint.call())
			planet.get_node("Sprite/Ocean").get_material().set_shader_parameter("rotation_speed",planet.get_node("Sprite").get_material().get_shader_parameter("rotation_speed"))
		else:
			planet.get_node("Sprite/Ocean").get_material().set_shader_parameter("base_color",planet.get_node("Ocean").get_true_color())
	if planet.has_node("Precipitation"):
		planet.get_node("Sprite/Atmosphere").get_material().set_shader_parameter("cloud_coverage",0.25*randf()+0.25)
		planet.get_node("Sprite/Atmosphere").get_material().set_shader_parameter("rotation_speed",planet.get_node("Sprite/Ocean").get_material().get_shader_parameter("rotation_speed")-0.4)
	return planet

func generate_system():
	var star = generate_star()
	
	for i in range(0,randi_range(3,6)):
		var planet = generate_planet(star)
		var angle = randf_range(0,TAU)
		planet.position = Vector2(planet.orbital_radius*cos(angle)*2048,planet.orbital_radius*sin(angle)*2048)
		planet.obj_name = star.obj_name+" - "+Constants.romanify(i+1)
		planet.get_node("InspectComponent").tt_title_text = planet.obj_name
		star.get_node("Satellites").add_child(planet)
	
	add_child(star)

func _on_generate_pressed():
	for c in get_children():
		if c.has_node("Sprite"):
			c.queue_free()
			remove_child(c)
			break
	generate_system()
