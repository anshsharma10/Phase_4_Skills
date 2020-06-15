extends Camera2D

#The player.
onready var player = get_parent()

func _ready():
	update_room()

#Sets the limit of the camera according to the current room
func update_room():
	print(get_tree().get_root().get_children())
	var rooms = get_tree().get_root().get_node("LevelTemplate").get_node("GroundMap").get_node("RoomMap").get_rooms()
	var pos = player.get_position()
	var i = 0
	while i < rooms.size() - 1:
		if pos.x >= rooms[i]*16 and pos.x <= rooms[i + 1]*16:
			limit_left = rooms[i]*16 + 48
			limit_right = rooms[i+1]*16 - 32
			break
		i += 1
