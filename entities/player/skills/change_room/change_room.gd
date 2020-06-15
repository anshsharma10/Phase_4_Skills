extends Node2D

#The player.
onready var player = get_parent()
#Player's camera
onready var camera = get_parent().get_node("PlayerCamera")
#The direction to move in. Default is left but it will change
var move_direction = -1
#The type of skill this is
var skill_type = "unique"

func _ready():
	#Make the raycast not consider the player
	$RayCast2D1.add_exception(player)
	$RayCast2D2.add_exception(player)
	#Find the direction to move to
	$RayCast2D1.force_raycast_update()
	$RayCast2D2.force_raycast_update()
	move_direction = 1 if $RayCast2D2.is_colliding() else -1
	
	#Move the player past the barrier
	player.move(Vector2(48*move_direction, 0))
	#Make the camera update
	camera.update_room()
	cancel()

#Stops the skill, deleting it
func cancel():
	#Delete the node
	$RayCast2D1.queue_free()
	$RayCast2D2.queue_free()
	queue_free()

func get_skill_type() ->String:
	return skill_type
