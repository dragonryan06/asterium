extends PanelContainer
class_name DialogPanelContainer

# PanelContainer but now with awesome interactivity! The possibilities!!!

signal destroying_dialog
signal destroying_subdialog(which:DialogPanelContainer)

const EDGE_WIDTH = 10
enum EDGES {NW,N,NE,E,SE,S,SW,W}

# enum edges, then center move
var disabled = [false,false,false,false,false,false,false,false,false]

var dragging = false
var edge = -1

# if left null, connecting_line just wont be used
var connecting_target : CanvasItem
var connecting_line : ConnectingLine

func _init() -> void:
	gui_input.connect(_on_gui_input)
	connecting_line = ConnectingLine.new()
	add_child(connecting_line)

func _process(_delta) -> void:
	if connecting_target!=null:
		connecting_line.connect_nodes(self,connecting_target)

func _on_gui_input(event:InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		dragging = true
		if mouse_default_cursor_shape == Control.CURSOR_ARROW and not disabled[8]:
			mouse_default_cursor_shape = Control.CURSOR_DRAG
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and !event.is_pressed():
		dragging = false
		if mouse_default_cursor_shape == Control.CURSOR_DRAG:
			mouse_default_cursor_shape = Control.CURSOR_ARROW
	elif event is InputEventMouseMotion and dragging:
		if mouse_default_cursor_shape == Control.CURSOR_DRAG and not disabled[8]:
			position+=event.relative
		else:
			var old_pos = position
			var old_size = size
			if !disabled[edge]:
				match edge:
					EDGES.NW:
						position+=event.relative
						size-=event.relative
					EDGES.N:
						position.y+=event.relative.y
						size.y-=event.relative.y
					EDGES.NE:
						size.x+=event.relative.x
						position.y+=event.relative.y
						size.y-=event.relative.y
					EDGES.E:
						size.x+=event.relative.x
					EDGES.SE:
						size+=event.relative
					EDGES.S:
						size.y+=event.relative.y
					EDGES.SW:
						size.y+=event.relative.y
						position.x+=event.relative.x
						size.x-=event.relative.x
					EDGES.W:
						position.x+=event.relative.x
						size.x-=event.relative.x
			if size.x == old_size.x:
				position.x = old_pos.x
			elif size.y == old_size.y:
				position.y = old_pos.y
	elif event is InputEventMouseMotion:
		if event.position.x<EDGE_WIDTH*4.5 and event.position.y<EDGE_WIDTH*4.5 and not disabled[EDGES.NW]:
			edge = EDGES.NW
			mouse_default_cursor_shape = Control.CURSOR_FDIAGSIZE
		elif event.position.x>size.x-EDGE_WIDTH*4.5 and event.position.y>size.y-EDGE_WIDTH*4.5 and not disabled[EDGES.SE]:
			edge = EDGES.SE
			mouse_default_cursor_shape = Control.CURSOR_FDIAGSIZE
		elif event.position.x<EDGE_WIDTH*2 and event.position.y>size.y-EDGE_WIDTH*2 and not disabled[EDGES.SW]:
			edge = EDGES.SW
			mouse_default_cursor_shape = Control.CURSOR_BDIAGSIZE
		elif event.position.x>size.x-EDGE_WIDTH*2 and event.position.y<EDGE_WIDTH*2 and not disabled[EDGES.NE]:
			edge = EDGES.NE
			mouse_default_cursor_shape = Control.CURSOR_BDIAGSIZE
		elif event.position.x<EDGE_WIDTH and not disabled[EDGES.W]:
			edge = EDGES.W
			mouse_default_cursor_shape = Control.CURSOR_HSPLIT
		elif event.position.x>size.x-EDGE_WIDTH and not disabled[EDGES.E]:
			edge = EDGES.E
			mouse_default_cursor_shape = Control.CURSOR_HSPLIT
		elif event.position.y<EDGE_WIDTH and not disabled[EDGES.N]:
			edge = EDGES.N
			mouse_default_cursor_shape = Control.CURSOR_VSPLIT
		elif event.position.y>size.y-EDGE_WIDTH and not disabled[EDGES.S]:
			edge = EDGES.S
			mouse_default_cursor_shape = Control.CURSOR_VSPLIT
		else:
			edge = -1
			mouse_default_cursor_shape = Control.CURSOR_ARROW
