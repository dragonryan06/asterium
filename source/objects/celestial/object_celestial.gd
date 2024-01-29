extends GenericObject
class_name CelestialObject

## This CelestialObject's mass, in its subclass's own relative unit system
var mass : float
## This CelestialObject's radius, in its sublcass's own relative unit system
var radius : float : set=_set_radius
## If null, this CelestialObject is the core of its own system
var orbital_parent : CelestialObject
## The time it takes this CelestialObject to complete one lap around its orbital_parent
var orbital_period : float # NOT YET IMPLEMENTED, KEPLER'S THIRD LAW SHOULD HELP
## The distance in AU at which this CelestialObject orbits its orbital_parent
var orbital_radius : float
## The time it takes this CelestialObject to complete one full rotation in seconds. Sign indicates direction.
var rotational_period : int : set=_set_rotational_period

func _set_radius(val:float) -> void:
	radius = val
	$Sprite.texture.width = 128*snapped(radius,0.25)
	$Sprite.texture.height = 64*snapped(radius,0.25)

func _set_rotational_period(val:int) -> void:
	rotational_period = val
	var vel = int(val/86400.0) # 1 rotation per day equals rotSpeed of 1.0
	$Sprite.get_material().set_shader_parameter("rotSpeed",abs(vel))
	var dir = vel/abs(vel)
	$Sprite.get_material().set_shader_parameter("rotDirection",Vector2(dir,0))
