extends PanelContainer

var changes_kept = false
var reverted_early = false

var _resolutions = [
	Vector2(648,648),
	Vector2(640,480),
	Vector2(720,480),
	Vector2(800,600),
	Vector2(1152,648),
	Vector2(1280,720),
	Vector2(1280,800),
	Vector2(1680,720),
	Vector2(2560,1080)
]

func fly_in():
	var tween = get_tree().create_tween().set_parallel()
	tween.set_trans(Tween.TRANS_SINE)
	tween.tween_property(self,"position",Vector2(252,0),0.5)
	tween.tween_property(self,"modulate",Color(1.0,1.0,1.0,1.0),0.5)

func fly_out():
	var tween = get_tree().create_tween().set_parallel()
	tween.set_trans(Tween.TRANS_SINE)
	tween.tween_property(self,"position",Vector2(252,649),0.5)
	tween.tween_property(self,"modulate",Color(1.0,1.0,1.0,0.0),0.5)

func _ready():
	var config = ResourceManager.get_or_create_settings()
	# init settings to config positions
	$MarginContainer/ScrollContainer/VBoxContainer/WindowMode/OptionButton.selected = config.get_value("VIDEO","WINDOW_MODE")
	$MarginContainer/ScrollContainer/VBoxContainer/Resolution/OptionButton.selected = _resolutions.find(config.get_value("VIDEO","RESOLUTION"))
	$MarginContainer/ScrollContainer/VBoxContainer/WindowStretch/OptionButton.selected = config.get_value("VIDEO","STRETCH_MODE")
	$MarginContainer/ScrollContainer/VBoxContainer/WindowStretchAspect/OptionButton.selected = config.get_value("VIDEO","STRETCH_ASPECT")
	$MarginContainer/ScrollContainer/VBoxContainer/WindowScaleFactor/HSlider.value = 100*config.get_value("VIDEO","SCALE_FACTOR")
	$MarginContainer/ScrollContainer/VBoxContainer/WindowScaleFactor/Val.text = str(int($MarginContainer/ScrollContainer/VBoxContainer/WindowScaleFactor/HSlider.value))+"%"
	$MarginContainer/ScrollContainer/VBoxContainer/WindowScaleMode/OptionButton.selected = config.get_value("VIDEO","SCALE_STRETCH_MODE")

func _emergency_revert() -> bool:
	$EmergencyRevert.visible = true
	var time_remaining = 10
	while time_remaining>0:
		var timer = get_tree().create_timer(0.1)
		$EmergencyRevert/Timer.text = str(time_remaining).pad_decimals(1)
		await timer.timeout
		time_remaining-=0.1
		if changes_kept:
			changes_kept = false
			$EmergencyRevert.visible = false
			return true
		elif reverted_early:
			reverted_early = false
			break
	$EmergencyRevert.visible = false
	return false

func _on_keep_changes_pressed():
	changes_kept = true

func _on_revert_now_pressed():
	reverted_early = true

func _on_apply_pressed():
	ProjectSettings.set_setting("display/window/size/mode",$MarginContainer/ScrollContainer/VBoxContainer/WindowMode/OptionButton.selected)
	DisplayServer.window_set_mode($MarginContainer/ScrollContainer/VBoxContainer/WindowMode/OptionButton.selected)
	var res = $MarginContainer/ScrollContainer/VBoxContainer/Resolution/OptionButton.selected
	ProjectSettings.set_setting("display/window/size/viewport_width",_resolutions[res].x)
	ProjectSettings.set_setting("display/window/size/viewport_height",_resolutions[res].y)
	DisplayServer.window_set_size(_resolutions[res])
	get_viewport().content_scale_mode = $MarginContainer/ScrollContainer/VBoxContainer/WindowStretch/OptionButton.selected
	get_viewport().content_scale_aspect = $MarginContainer/ScrollContainer/VBoxContainer/WindowStretchAspect/OptionButton.selected
	get_viewport().content_scale_factor = $MarginContainer/ScrollContainer/VBoxContainer/WindowScaleFactor/HSlider.value/100.0
	get_viewport().content_scale_stretch = $MarginContainer/ScrollContainer/VBoxContainer/WindowScaleMode/OptionButton.selected
	if await _emergency_revert():
		var config = ConfigFile.new()
		config.set_value("VIDEO","WINDOW_MODE",ProjectSettings.get_setting("display/window/size/mode"))
		config.set_value("VIDEO","RESOLUTION",_resolutions[res])
		config.set_value("VIDEO","STRETCH_MODE",get_viewport().content_scale_mode)
		config.set_value("VIDEO","STRETCH_ASPECT",get_viewport().content_scale_aspect)
		config.set_value("VIDEO","SCALE_FACTOR",get_viewport().content_scale_factor)
		config.set_value("VIDEO","SCALE_STRETCH_MODE",get_viewport().content_scale_stretch)
		config.save("user://settings.cfg")
	else:
		var settings = ResourceManager.get_or_create_settings()
		ProjectSettings.set_setting("display/window/size/mode",settings.get_value("VIDEO","WINDOW_MODE"))
		DisplayServer.window_set_mode(settings.get_value("VIDEO","WINDOW_MODE"))
		ProjectSettings.set_setting("display/window/size/viewport_width",settings.get_value("VIDEO","RESOLUTION").x)
		ProjectSettings.set_setting("display/window/size/viewport_height",settings.get_value("VIDEO","RESOLUTION").y)
		DisplayServer.window_set_size(settings.get_value("VIDEO","RESOLUTION"))
		get_viewport().content_scale_mode = settings.get_value("VIDEO","STRETCH_MODE")
		get_viewport().content_scale_aspect = settings.get_value("VIDEO","STRETCH_ASPECT")
		get_viewport().content_scale_factor = settings.get_value("VIDEO","SCALE_FACTOR")
		get_viewport().content_scale_stretch = settings.get_value("VIDEO","SCALE_STRETCH_MODE")
		_ready()

func _on_h_slider_value_changed(value):
	$MarginContainer/ScrollContainer/VBoxContainer/WindowScaleFactor/Val.text = str(int(value))+"%"

func _on_exit_pressed():
	fly_out()
