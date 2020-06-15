extends TileMap

#The map, represented by a grid
var grid = []
#Length of the map
var length = randi() % 100 + 500
#Height of the map
var height = 100
#Ground level
var ground_level = 50
#Frequency of hills
var frequency = 0.5

func _ready():
	#Initialize grid
	grid.resize(length)
	for i in range(length):
		grid[i] = []
		grid[i].resize(height)
	
	#Add the ground
	draw_ground()
	
	#Draw the houses
	draw_houses()
	
	#Set all cells and update their bitmask
	set_cells()
	update_bitmask()
	
	#Create rooms
	$RoomMap.draw_rooms()

#Draws the ground
func draw_ground():
	#Offset from regular ground level
	for x in range(length):
		var offset_sign = [-1, 1]
		randomize()
		var offset = 0
		var rand = randf()
		if rand < 0.1*frequency:
			offset += offset_sign[randi() % 2] * 1
		if rand < 0.05*frequency:
			randomize()
			offset += offset_sign[randi() % 2] * randi() % 4
		if rand < 0.002*frequency:
			randomize()
			offset += offset_sign[randi() % 2] * randi() % 10
		#draw the cliff
		ground_level = ground_level + offset if (0 < ground_level + offset and height > ground_level + offset) else ground_level - offset
		fill_rect(x,ground_level,1,height - ground_level,0)

#Gets the ground level for a certain x position
func get_ground(x: int) -> int:
	for y in range(height):
		#Check if ground has been found at the point
		if grid[x][y] == 0:
			return y
	#If no ground found, return the lowest point
	return height - 1

#Draws houses
func draw_houses():
	#Don't draw houses in the first/last 10 blocks of the map
	var i = 10
	while (i < length - 10):
		#Check if next five blocks are the same
		var same = true
		for j in range(6):
			if get_ground(i) != get_ground(i + j):
				same = false
		#If they're the same, then add a house
		if same:
			i+= 1
			grid[i][get_ground(i) - 5] = 1
			i+= 3
			#Decide whether or not to add a gap in between houses
			randomize()
			var rand = randf()
			if rand < 0.1:
				i += 1
			if rand < 0.05:
				i += randi() % 10
		i+= 1

func generate_rooms():
	pass

#Flips grid vertically
func flip_y():
	for x in range(length):
		for y in range(height/2):
			var temp = grid[x][y]
			grid[x][y] = grid[x][height - y - 1]
			grid[x][height - y - 1] = temp

#Updates the bitmask of every tile within the area
func update_bitmask():
	update_bitmask_region(Vector2(0,0),Vector2(length - 1, height - 1))

#Draws a rectangle on the grid at the specific points with tile
func fill_rect(x_pos: int, y_pos: int, x_size: int, y_size: int, tile: int):
	for i in range(x_size):
		for j in range(y_size):
			grid[x_pos + i][y_pos + j] = tile

#Inserts a tile onto each position in the level depending on their respective grid values
func set_cells():
	for x in range(grid.size()):
		for y in range(height):
			if grid[x][y] != null:
				set_cell(x, y, grid[x][y])

func get_length() -> int:
	return length

func get_height() -> int:
	return height
