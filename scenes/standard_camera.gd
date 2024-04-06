extends Camera2D

signal camera_changed

const POS_SPEED = 20
const ZOOM_SPEED = 0.01

var pos_velocity = Vector2(0.0,0.0)
var zoom_velocity = 0.0

func _physics_process(delta):
	if Input.is_action_pressed("camera_move_up"):
		pos_velocity.y-=POS_SPEED*1.0/zoom.x
	if Input.is_action_pressed("camera_move_left"):
		pos_velocity.x-=POS_SPEED*1.0/zoom.x
	if Input.is_action_pressed("camera_move_down"):
		pos_velocity.y+=POS_SPEED*1.0/zoom.x
	if Input.is_action_pressed("camera_move_right"):
		pos_velocity.x+=POS_SPEED*1.0/zoom.x
	if Input.is_action_pressed("camera_zoom_in"):
		zoom_velocity+=ZOOM_SPEED
	if Input.is_action_pressed("camera_zoom_out"):
		zoom_velocity-=ZOOM_SPEED
	
	position+=pos_velocity*delta
	if pos_velocity*delta!=Vector2(0.0,0.0):
		camera_changed.emit()
	
	if zoom.x+zoom_velocity*delta<=0.01:
		zoom = Vector2(0.01,0.01)
		zoom_velocity = 0.0
		if pos_velocity*delta==Vector2(0.0,0.0):
			camera_changed.emit()
	else:
		zoom+=Vector2(zoom_velocity,zoom_velocity)*delta
		if pos_velocity*delta==Vector2(0.0,0.0) and Vector2(zoom_velocity,zoom_velocity)*delta!=Vector2(0.0,0.0):
			camera_changed.emit()
	
	if pos_velocity.x>0 and pos_velocity.x-0.5*POS_SPEED*1.0/zoom.x>0:
		pos_velocity.x-=0.5*POS_SPEED*1.0/zoom.x
	elif pos_velocity.x<0 and pos_velocity.x+0.5*POS_SPEED*1.0/zoom.x<0:
		pos_velocity.x+=0.5*POS_SPEED*1.0/zoom.x
	else:
		pos_velocity.x=0
	if pos_velocity.y>0 and pos_velocity.y-0.5*POS_SPEED*1.0/zoom.x>0:
		pos_velocity.y-=0.5*POS_SPEED*1.0/zoom.x
	elif pos_velocity.y<0 and pos_velocity.y+0.5*POS_SPEED*1.0/zoom.x<0:
		pos_velocity.y+=0.5*POS_SPEED*1.0/zoom.x
	else:
		pos_velocity.y=0
	
	if zoom_velocity>0 and zoom_velocity-0.5*ZOOM_SPEED>0:
		zoom_velocity-=0.5*ZOOM_SPEED
	elif zoom_velocity<0 and zoom_velocity+0.5*ZOOM_SPEED<0:
		zoom_velocity+=0.5*ZOOM_SPEED
	else:
		zoom_velocity = 0

# this is so that tween_method() can call camera_changed.emit()
func _update_camera(_null):
	camera_changed.emit()

func _on_camera_focus_object(object:Node2D) -> void:
	var tween = get_tree().create_tween().set_parallel()
	tween.tween_property(self,"position",object.position,0.5).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self,"zoom",Vector2(0.1,0.1),0.5).set_trans(Tween.TRANS_CUBIC)
	tween.tween_method(_update_camera,null,null,1.0)
	await tween.finished
	camera_changed.emit()
