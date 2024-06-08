extends Node2D

## Render a 2d x-y grid with given color based on the zoom of parent Camera2D

@export var fade_curve : Curve
@export var color = Color(0.25,0.25,1.0,1.0)

const font = preload("res://fonts/PixelOperator8-Bold.ttf")

func _input(event):
	if event.is_action_pressed("toggle_grid"):
		visible = !visible

func _ready() -> void:
	get_parent().camera_changed.connect(_on_camera_changed)

func _on_camera_changed() -> void:
	queue_redraw()

func get_camera_rect() -> Rect2:
	var half_size = get_viewport_rect().size * 0.5 * 1.0/get_parent().zoom.x
	return Rect2(-half_size,half_size*2.0)


func _draw() -> void:
	# linear axes
	var rect = get_camera_rect()
	draw_line(rect.position+Vector2(rect.size.x*0.5-global_position.x,0),rect.position+Vector2(rect.size.x*0.5-global_position.x,rect.size.y),Color("Blue",0.5))
	draw_line(rect.position+Vector2(0,rect.size.y*0.5-global_position.y),rect.position+Vector2(rect.size.x,rect.size.y*0.5-global_position.y),Color("Blue",0.5))
	draw_line(rect.position+Vector2(-0.5*(rect.size.y+2*global_position.y)*tan(deg_to_rad(45))+rect.size.x*0.5-global_position.x,rect.size.y),rect.position+Vector2(0.5*rect.size.y-global_position.y*tan(deg_to_rad(45))+rect.size.x*0.5-global_position.x,0),Color("Blue",0.5))
	draw_line(rect.position+Vector2(-0.5*(rect.size.y-2*global_position.y)*tan(deg_to_rad(45))+rect.size.x*0.5-global_position.x,0),rect.position+Vector2(0.5*rect.size.y+global_position.y*tan(deg_to_rad(45))+rect.size.x*0.5-global_position.x,rect.size.y),Color("Blue",0.5))
	
	
	var screen_au = (rect.size.x/2.0)/2048
	
	if screen_au<4.0:
		# 0.5 AU units
		draw_radial_grid(0.5,fade_curve.sample((screen_au/4.0)),rect)
	if screen_au>2.0 and screen_au<8.0:
		# 1.0 AU units
		draw_radial_grid(1.0,fade_curve.sample((screen_au/8.0)),rect)
	if screen_au>4.0 and screen_au<16.0:
		# 2.0 AU units
		draw_radial_grid(2.0,fade_curve.sample((screen_au/16.0)),rect)
	if screen_au>8.0 and screen_au<40.0:
		# 5.0 AU units
		draw_radial_grid(5.0,fade_curve.sample((screen_au/40.0)),rect)
	
	#for i in range(0,screen_au+4):
		#var alpha = fade_curve.sample(i/float(snapped(i/2.0,1)))
		#draw_arc(rect.position+rect.size*0.5-global_position,i*2048,0,TAU,64,Color("Blue",0.5*alpha))
		#elif i%(radius/2)==0:
			#draw_arc(rect.position+rect.size*0.5-global_position,i,deg_to_rad(-5.625),deg_to_rad(5.625),64,Color("Blue",0.5*xfader))
			#draw_arc(rect.position+rect.size*0.5-global_position,i,deg_to_rad(84.375),deg_to_rad(95.625),64,Color("Blue",0.5*xfader))

func draw_radial_grid(unit_size:float,alpha:float,rect:Rect2) -> void:
	#for i in range((global_position.length()+rect.position.length())/4096.0,(global_position.length()+rect.position.length()+rect.size.length())/4096.0):
	for i in range(rect.position.x,rect.size.x):
		if i%int(unit_size*2048)==0:
			draw_arc(rect.position+rect.size*0.5-global_position,i,0,TAU,64,Color("Blue",0.5*alpha))

	#var rect = get_camera_rect()
	#var width = (rect.size.x-rect.position.x)/2048
	#if width<32.0:
		#var alpha = fade_curve.sample(width/32.0)
		#draw_grid(rect,2048,alpha) # 1x1
		#draw_string(font,to_local(Vector2(100,-100)),"1 AU",HORIZONTAL_ALIGNMENT_LEFT,-1,16*1.0/(get_parent().zoom.x),Color(color,alpha))
	#if width>24.0 and width<128.0:
		#var alpha = fade_curve.sample(width/128.0)
		#draw_grid(rect,10240,alpha) # 5x5
		#draw_string(font,to_local(Vector2(400,-100)),"5 AU",HORIZONTAL_ALIGNMENT_LEFT,-1,16*1.0/(get_parent().zoom.x),Color(color,alpha))

#func draw_grid(rect:Rect2,size:int,alpha:float) -> void:
	#for i in range(rect.position.x,rect.size.x):
		#if i%size==0:
			#draw_line(to_local(Vector2(i,rect.position.y)),to_local(Vector2(i,rect.size.y)),Color(color,alpha),5.0*1.0/(get_parent().zoom.x*1.5))
	#for i in range(rect.position.y,rect.size.y):
		#if i%size==0:
			#draw_line(to_local(Vector2(rect.position.x,i)),to_local(Vector2(rect.size.x,i)),Color(color,alpha),5.0*1.0/(get_parent().zoom.x*1.5))
