extends KinematicBody2D

const FLOOR_NORMAL = Vector2.UP

#In-game velocity
var velocity: = Vector2.ZERO
#List of all velocities to compute into total velocity
var velocities = []
#Whether or not the actor can do anything
var allow_enemy_input = true

var data = {
	"speed": Vector2(500.0, 1100.0),
	"gravity": 500.0,
	"time_scale": 1,
}

func _physics_process(delta):
	var total_velocity = Vector2.ZERO
	#Determine the velocity controlled by the enemy, depending on whether or not they can move
	if allow_enemy_input:
		add_velocity(calculate_move_velocity(), "input", "remove", 0)
	#Add together all velocities, including enemy-controlled and outside factors
	for vel_array in velocities:
		total_velocity += vel_array[0]
	#Apply gravity
	total_velocity.y += data.get("gravity")*delta*total_time_scale()
	#Apply time scale
	total_velocity *= total_time_scale()
	#Add together player-controlled and outside velocity to determine final velocity
	velocity = move_and_slide_with_snap(total_velocity, Vector2.ZERO,  FLOOR_NORMAL, false, 4, PI/4, false)
	#Account for total time scale
	velocity /= total_time_scale()
	#print(velocities)
	#Modify all velocities
	modify_velocities()

func calculate_move_velocity() -> Vector2: #Calculate the velocity the player will move at
	var out: = velocity
	
	out.x *= 0.91

	return out

#Adds a velocity to the list of velocities.
func add_velocity(input_velocity: Vector2, name: String, type: String, factor: float):
	#input_velocity is the velocity to add.
	#name is the name of the velocity
	#type is the type of velocity:
	#	remove will be removed after one frame
	#	scale will scale up or down depending on the factor value
	velocities.append([input_velocity, name, type, factor])

#Iterates through all velocities and modifies them as required by their type.
func modify_velocities():
	for i in range(velocities.size() - 1, -1, -1):
		if velocities[i][2] == "remove" or velocities[i][0].length() < 0.00001:
			velocities.remove(i)
		elif velocities[i][2] == "scale":
			velocities[i][0] *= velocities[i][3]

#Removes a velocity from the list of velocities
func remove_velocity(name: String):
	for i in range(velocities.size() - 1, -1, -1):
		if velocities[i][1] == name:
			velocities.remove(i)

func _on_Hitbox_area_entered(area):
	if area.name == "player_hitbox":
		remove_velocity("gravity")
		add_velocity(area.get_parent().get_direction(), "damage", "remove", 0)

func total_time_scale() -> float:
	return get_parent().get_node("LevelInfo").get_data().get("time_scale") * data.get("time_scale")
