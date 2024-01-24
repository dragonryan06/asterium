extends Control

#NOTE maybe change inspection to be a shift-click thing and not a hover-indication thing
# i just dont know with the variable shapes of ships how to make it feel consistent.

const formats = {
	"star": {
		"title":"[NAME]",
		"subtitle":"[CLASS]",
		"details":"[u]Rotational Period:[/u] xyzabc\n[u]Chromaticity:[/u] [CHROMATICITY]\n[u]Surface Temperature:[/u] [TEMPERATURE] K\n[u]Radius:[/u] [RADIUS] R*\n[u]Mass:[/u] [MASS] M*",
		"description":"\t[NAME] is a large sphere composed of plasma. It is constantly fusing atoms together, converting a fraction of their mass into energy each time. \n\tIt is the heart of the [NAME] system, and provides the [CHROMATICITY] illumination seen in its satellites' skies"
	}
}

func inspect(obj) -> void:
	if not "obj_type" in obj:
		return
	elif obj.obj_type == "star": # obj_types could be star, planet, moon, starship, station... (wreckage, asteroid fields)
		print("star inspected")
