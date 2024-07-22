extends DialogPanelContainer
class_name SidebarMenu

var default_size : Vector2

func _init() -> void:
	super._init()
	disabled = [true,true,true,true,true,true,true,false,true]

func _ready() -> void:
	default_size = size
	$MarginContainer/Toggle.toggled.connect(toggle_menu)

func _input(event:InputEvent) -> void:
	if event.is_action_pressed("ui_minimize_all"):
		$MarginContainer/Toggle.toggled.emit(true)
		$MarginContainer/Toggle.set_pressed_no_signal(false)

func toggle_menu(state:bool) -> void:
	print($MarginContainer/Toggle.button_pressed)
	if state:
		var tween = get_tree().create_tween().set_parallel()
		tween.tween_property(self,"position",Vector2(1152,0),0.5).set_trans(Tween.TRANS_CUBIC)
		tween.tween_property(self,"size",default_size,0.5).set_trans(Tween.TRANS_CUBIC)
	else:
		var tween = get_tree().create_tween().set_parallel()
		tween.tween_property(self,"position",Vector2(883,0),0.5).set_trans(Tween.TRANS_CUBIC)
		tween.tween_property(self,"size",default_size,0.5).set_trans(Tween.TRANS_CUBIC)
