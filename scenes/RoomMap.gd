extends TileMap

onready var ground_map = get_parent()

onready var length = get_parent().get_length()

onready var height = get_parent().get_height()

enum {START, #Start of the level. Absolutely cannot be passed
 BARRIER, #When the player touches it, they move to the next level. Shared between levels
 END} #End of the level. Absolutely cannot be passed.

#Each coordinate is the start or end of a room, either from BORDER, START, or END
var rooms = [0]

func draw_rooms():
	var i = 0
	#Create start/end
	create_border(0, START)
	create_border(length - 1, END)
	while i < length:
		randomize()
		var rand = randf()
		#small room
		if rand < 0.15:
			i += 40 + randi() % 30
		#large room
		elif rand > 0.85:
			i += 100 + randi() % 50
		#medium room
		else:
			i += 80 + randi() % 30
		#Account for rooms too big in length near the end
		if i >= length - 10:
			break
		#Add walls
		create_border(i + 2, BARRIER)
		#Add this room border to the list of room borders
		rooms.append(i + 2)
	#Add the final room border
	rooms.append(length - 1)
	
	$CameraMap.draw_borders(rooms)

#Creates a border with a specified barrier type at the x location of the map
func create_border(x: int, type: int):
	for y in range(height + 200):
		set_cell(x, y - 200, type)

func get_rooms() -> Array:
	return rooms
