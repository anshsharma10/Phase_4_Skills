extends Node2D

#represents the player
onready var player = get_parent()
#whether or not the player can currently initiate a skill
var can_use_skill = true
#Number of frames the buffer is active for.
const buffer_frames = 5
#Contains the history of previous inputs for 5 frames. each array contains every input made during that frame.
var input_buffer = []

func _ready():
	#populate the buffer array with blank frames
	for i in range(buffer_frames):
		input_buffer.push_front(null)

func _process(delta):
	#If the user performed an input event, add it to an array and add this array to the input_buffer
	var frame_inputs = []
	if check_press("move_left"):
		frame_inputs.append("move_left")
	if check_press("move_right"):
		frame_inputs.append("move_right")
	if check_initial_press("jump"):
		frame_inputs.append("jump")
	if check_press("move_down"):
		frame_inputs.append("move_down")
	if check_press("walk_toggle"):
		frame_inputs.append("walk_toggle")
	if check_press("click_1"):
		frame_inputs.append("click_1")
	#Add this frame to the beginning of the buffer, then remove the end frame, keeping the array's length
	input_buffer.push_front(frame_inputs)
	input_buffer.pop_back()
	
	#check if attacking
	if (input_buffered("click_1",-1) >= 0 and player.is_on_floor() and can_use_skill and not player.has_node("side_tilt")):
		add_skill("side_tilt")
	
	#check if sliding
	if (input_combo_buffered(["move_left","move_down"], 2) >= 0 or input_combo_buffered(["move_right","move_down"], 2) >= 0) and player.is_on_floor() and can_use_skill and not player.has_node("skill_slide"):
		add_skill("slide")
	
	#check if jumping
	if (input_buffered("jump",-1) >= 0 and player.is_on_floor() and can_use_skill and not player.has_node("skill_jump") and player.get_velocity().y <= 0):
		add_skill("jump")
	
	#check if sliding against wall (and not a barrier)
	if player.is_on_wall() and not player.is_on_floor() and can_use_skill and not player.has_node("skill_wall_slide") and not player.against_barrier():
		add_skill("wall_slide")
	
	#check if against barrier
	if player.against_barrier() and not player.has_node("skill_change_room"):
		add_skill("change_room")
	
	#Check if pressed space to pause
	if check_press("pause"):
		Engine.time_scale = 0
	else:
		Engine.time_scale = 1
	
	#print(input_buffer)

#Checks to see if the requested input has been buffered.
#Frames is the number of frames to check. -1 means check all frames.
#Returns the number of frames since now the input has been pressed.
#Returns -1 if it hasn't been inputted
func input_buffered(input: String, frames: int) -> int:
	if frames == -1:
		frames = buffer_frames
	for i in range(frames):
		if input_buffer[i] != null and input_buffer[i].find(input) != -1:
			return i
	return -1

#Checks to see if a combination of inputs has been buffered.
#Frames is the number of frames to check. -1 means check all frames.
#Returns the number of frames since now the inputs have been pressed.
#Returns -1 if it hasn't been inputted
func input_combo_buffered(input: Array, frames: int) -> int:
	if frames == -1:
		frames = buffer_frames
	for i in range(frames):
		if input_buffer[i] != null:
			var all_found = true
			for j in range(input.size()):
				if input_buffer[i].find(input[j]) == -1:
					all_found = false
			if all_found:
				return i
	return -1

#Returns the current buffer
func get_buffer() -> Array:
	return input_buffer

#Sets can_use_skill to a particular value
func set_can_use_skill(value: bool):
	can_use_skill = value

#Checks if an input key has been pressed regardless of whether this is the first frame
func check_press(key: String) -> bool:
	return Input.is_action_just_pressed(key) or Input.is_action_pressed(key)

#Check if an input key has been pressed, but only on the first frame.
func check_initial_press(key: String) -> bool:
	return Input.is_action_just_pressed(key)

#Check the type of skill input and make changes to the player depending on it
func check_skill_type(skill: Node2D):
	if skill.get_skill_type() == "active":
		can_use_skill = false

func add_skill(skill: String):
	var scene = load("res://entities/player/skills/" + skill + "/" + skill + ".tscn").instance()
	scene.set_name("skill_" + skill)
	player.add_child(scene)
	check_skill_type(scene)
