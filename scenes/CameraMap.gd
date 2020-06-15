extends TileMap

onready var length = get_parent().get_parent().get_length()

onready var height = get_parent().get_parent().get_height()

func draw_borders(rooms: Array):
	for room in rooms:
		create_border(room - 2)
		create_border(room + 2)

#Creates a border with a camera block at the x location of the map
func create_border(x: int):
	for y in range(height + 200):
		set_cell(x, y - 200, 0)
