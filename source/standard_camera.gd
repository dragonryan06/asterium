extends Camera2D

const POS_SPEED = 20
const ZOOM_SPEED = 0.01

var pos_velocity = Vector2(0.0,0.0)
var zoom_velocity = 0.0

func _physics_process(delta):
	if Input.is_action_pressed("camera_move_up"):
		pos_velocity.y-=POS_SPEED
	if Input.is_action_pressed("camera_move_left"):
		pos_velocity.x-=POS_SPEED
	if Input.is_action_pressed("camera_move_down"):
		pos_velocity.y+=POS_SPEED
	if Input.is_action_pressed("camera_move_right"):
		pos_velocity.x+=POS_SPEED
	if Input.is_action_pressed("camera_zoom_in"):
		zoom_velocity+=ZOOM_SPEED
	if Input.is_action_pressed("camera_zoom_out"):
		zoom_velocity-=ZOOM_SPEED
	
	position+=pos_velocity*delta
	if zoom.x+zoom_velocity<=0.0:
		zoom = Vector2(0.1,0.1)
		zoom_velocity = 0.0
	else:
		zoom+=Vector2(zoom_velocity,zoom_velocity)
	
	if pos_velocity.x>0 and pos_velocity.x-0.5*POS_SPEED>0:
		pos_velocity.x-=0.5*POS_SPEED
	elif pos_velocity.x<0 and pos_velocity.x+0.5*POS_SPEED<0:
		pos_velocity.x+=0.5*POS_SPEED
	else:
		pos_velocity.x=0
	if pos_velocity.y>0 and pos_velocity.y-0.5*POS_SPEED>0:
		pos_velocity.y-=0.5*POS_SPEED
	elif pos_velocity.y<0 and pos_velocity.y+0.5*POS_SPEED<0:
		pos_velocity.y+=0.5*POS_SPEED
	else:
		pos_velocity.y=0
	
	if zoom_velocity>0 and zoom_velocity-0.5*ZOOM_SPEED>0:
		zoom_velocity-=0.5*ZOOM_SPEED
	elif zoom_velocity<0 and zoom_velocity+0.5*ZOOM_SPEED<0:
		zoom_velocity+=0.5*ZOOM_SPEED
	else:
		zoom_velocity = 0
