extends Node2D

## Render a 2d x-y grid with given color based on the zoom of parent Camera2D

@export var fade_curve : Curve
@export var color = Color(0.25,0.25,1.0,1.0)

const font = preload("res://assets/fonts/PixelOperator8-Bold.ttf")

func _ready() -> void:
	get_parent().camera_changed.connect(_on_camera_changed)

func _on_camera_changed() -> void:
	queue_redraw()

func get_camera_rect() -> Rect2:
	var pos = get_parent().global_position
	var half_size = get_viewport_rect().size * 0.5 * 1.0/get_parent().zoom.x
	return Rect2(pos - half_size, pos + half_size)

func draw_grid(rect:Rect2,size:int,alpha:float) -> void:
	for i in range(rect.position.x,rect.size.x):
		if i%size==0:
			draw_line(to_local(Vector2(i,rect.position.y)),to_local(Vector2(i,rect.size.y)),Color(color,alpha),5.0*1.0/(get_parent().zoom.x*1.5))
	for i in range(rect.position.y,rect.size.y):
		if i%size==0:
			draw_line(to_local(Vector2(rect.position.x,i)),to_local(Vector2(rect.size.x,i)),Color(color,alpha),5.0*1.0/(get_parent().zoom.x*1.5))

func _draw() -> void:
	var rect = get_camera_rect()
	var width = (rect.size.x-rect.position.x)/2048
	if width<32.0:
		var alpha = fade_curve.sample(width/32.0)
		draw_grid(rect,2048,alpha) # 1x1
		draw_string(font,to_local(Vector2(100,-100)),"1 AU",HORIZONTAL_ALIGNMENT_LEFT,-1,16*1.0/(get_parent().zoom.x),Color(color,alpha))
	if width>24.0 and width<128.0:
		var alpha = fade_curve.sample(width/128.0)
		draw_grid(rect,10240,alpha) # 5x5
		draw_string(font,to_local(Vector2(400,-100)),"5 AU",HORIZONTAL_ALIGNMENT_LEFT,-1,16*1.0/(get_parent().zoom.x),Color(color,alpha))
