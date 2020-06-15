extends KinematicBody2D

const FLOOR_NORMAL = Vector2.UP

#In-game velocity
var velocity: = Vector2.ZERO
#List of all velocities to compute into total velocity
var velocities = []
#Whether or not the actor can do anything
var allow_player_input = true
#All general data for the player
var data = {
	"speed": Vector2(200.0, 275.0),
	"gravity": 500.0,
	"room": 0,
	"time_scale": 1,
}


func _physics_process(delta):
	#Handle movement
	var direction: = get_direction()
	var total_velocity = Vector2.ZERO
	#Determine the velocity controlled by the player, depending on whether or not they can move
	if allow_player_input:
		add_velocity(calculate_move_velocity(), "input", "remove", 0)
	#Add together all velocities, including player-controlled and outside factors
	for vel_array in velocities:
		total_velocity += vel_array[0]
	#Apply gravity
	total_velocity.y += data.get("gravity")*delta*total_time_scale()
	#Apply time scale
	total_velocity *= total_time_scale()
	#Move and slide the player given total input velocities
	velocity = move_and_slide_with_snap(total_velocity, get_snap(),  FLOOR_NORMAL, false, 4, PI/4, false)
	#Account for total time scale
	velocity /= total_time_scale()
	#print(velocities)
	#Modify all velocities
	modify_velocities()

func _process(delta):
	$AnimationPlayer.animate()
	#Uncomment if need to check fps
	#print(Engine.get_frames_per_second())

func calculate_move_velocity() -> Vector2: #Calculate the velocity the player will move at
	var out: = velocity
	var direction = get_direction()
	var speed = data.get("speed")
	
	#sprinting
	out.x = speed.x * direction.x
	#walking
	if $SkillManager.input_buffered("walk_toggle",1) >= 0 and direction.x != 0: 
		out.x = speed.x * direction.x * 2/3.0

	#fast fall
	if $SkillManager.input_buffered("move_down",-1) >= 0 and not is_on_floor() and not has_node("skill_jump"): 
		out.y += data.get("gravity")*get_physics_process_delta_time()*0.5
	
	return out

func get_direction() -> Vector2: #Output horizontal and vertical vector based on input
	var out: = Vector2.ZERO
	out.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	if $SkillManager.input_buffered("jump",-1) >= 0 and is_on_floor():
		out.y = -1.0
	else:
		out.y = 1.0
	return out

func get_snap() -> Vector2: #Generate/Return snap vector for move and slide with snap
	var snap = Vector2(0,5) if not (is_jumping()) else Vector2.ZERO
	return snap

func facing_right() -> bool: #Return true if facing to the right, false if facing left
	return $Sprite.flip_h == false

func get_velocity() -> Vector2: #Return workable velocity
	return Vector2(velocity.x, velocity.y)

func set_velocity(velocity_in: Vector2): #Take a wild guess
	velocity = velocity_in

func is_jumping() -> bool: #Return true if player is in the process of jumping
	return $SkillManager.input_buffered("jump",-1) >= 0

func is_jump_interrupted() -> bool: #Return true if user has just released the jump key
	return Input.is_action_just_released("jump") and velocity.y < 0.0

func allow_player_input(input: bool):
	allow_player_input = input

func get_data() -> Dictionary:
	return data

func total_time_scale() -> float:
	return get_parent().get_node("LevelInfo").get_data().get("time_scale") * data.get("time_scale")

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

#Returns whether or not the player is currently touching a barrier made by RoomMap
func against_barrier() -> bool:
	var against_barrier = false
	for i in get_slide_count():
		var collision = get_slide_collision(i)
		if collision.collider.name == "RoomMap":
			against_barrier = true
	return against_barrier

#Moves the player certain # of pixels in a direction
func move(movement: Vector2):
	position += movement
