extends Node
class_name DescGen

static func _format(what:String,ctx:Dictionary) -> String:
	while what.find("§") != -1:
		var code = what.substr(what.find("§")+1,abs(what.find("§")-what.find("{"))-1)
		match code:
			"V":
				var data
				var path
				if what[what.find("{")+1]=="$":
					var nodepath = what.substr(what.find("$")+1,abs(what.find("$")-what.find("."))-1).split("/")
					data = ctx["planet"].get_node(nodepath[0])
					for i in range(1,len(nodepath)):
						data = data.get_node(nodepath[i])
					path = what.substr(what.find("$")+1,abs(what.find("{")-what.find("}"))-2).split(".")
				else:
					path = what.substr(what.find("{")+1,abs(what.find("{")-what.find("}"))-1).split(".")
					data = ctx[path[0]]
				for i in range(1,len(path)):
					if data.get(path[i]) is Callable:
						data = data.get(path[i]).call()
					else:
						data = data.get(path[i])
						if path[i]=="reagent_name":
							data = data.replace("_"," ")
				if data is Color:
					data = data.to_html(false)
				what = what.substr(0,what.find("§"))+str(data)+what.substr(what.find("}")+1,-1)
			"D":
				match what.substr(what.find("{")+1,abs(what.find("{")-what.find("}")+1)):
					"ROCK_DESCRIPTOR":
						var rock_data = ResourceManager.load_json("res://gamedata/chemistry/rocks.json").data
						for d in rock_data.keys():
							if rock_data[d].has(ctx["planet"].get_node("Bedrock").solution_name.to_lower()):
								what = what.substr(0,what.find("§"))+rock_data[d][ctx["planet"].get_node("Bedrock").solution_name.to_lower()]["descriptor"]+what.substr(what.find("}")+1,-1)
			_:
				print("DescGen _format(String) found unknown code in\n"+what)
				return what
	return what

static func make_planet_profile(planet:Planet,base:Dictionary,star:Star,satellite_idx:int) -> Dictionary:
	var out = {
		"name":"NAME",
		"desc":"DESC"
	}
	# for passing on vars to formatters
	var ctx = {"planet":planet,"base":base,"star":star,"satellite_idx":satellite_idx,"out":out}
	
	# name
	out["name"] = star.obj_name+" - "+Constants.romanify(satellite_idx+1)
	
	# description
	out["desc"] = "[b]"+base["basic"]["name"]+"[/b]\n"+_format(base["basic"]["base_sentence"],ctx)
	
	return out
