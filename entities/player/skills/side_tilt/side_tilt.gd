extends Node2D

const FLOOR_NORMAL = Vector2.UP

#This is a skill; should be instantiated inside of the player ONLY.

#The player.
onready var player = get_parent()
#The player's animation player
onready var animation_player = player.get_node("AnimationPlayer")
#The skill manager.
onready var skill_manager = get_parent().get_node("SkillManager")
#The area2D containing all hitboxes
onready var player_hitbox = get_node("player_hitbox")
#The animation player animating each hitbox
onready var hitbox_player = get_node("HitboxPlayer")
#The type of skill this is
var skill_type = "active"
#The length, taken from frame data
var anim_time = 0.6
#The time scale of the animation
var anim_scale = 1
#The damage given by the attack.
var damage = 1
#The vector the attack launches the enemy in
var direction = Vector2(160,-160)
#The direction the player faces in
var attack_dir

func _ready():
	#Make sure the player can't input anything for the duration of this
	player.allow_player_input(false)
	#Make sure the player can't activate any skills for the duration of this
	skill_manager.set_can_use_skill(false)
	#Keep the player's old velocity
	player.add_velocity(player.get_velocity()*0.85, name, "scale", 0.85)
	
	startup()

func _physics_process(delta):
	if not player.is_on_floor():
		cancel()

func startup(): #Perform the startup of the move in startup_lag time.
	#Order the animation player to do the startup animation
	animation_player.command_animate("slash1","face_on_mouse",true, 0, anim_scale)
	#Order the skill's hitbox animation player to do the startup animation
	hitbox_player.command_animate("attack","face_on_mouse",true, 0, anim_scale)
	direction.x = direction.x if player.facing_right() else direction.x*-1

func cancel():
	#Cancel the player's velocity
	player.remove_velocity(name)
	#Stop the animations
	animation_player.end_animation()
	hitbox_player.end_animation()
	#Let the player move again
	player.allow_player_input(true)
	#Let the player activate skills again
	skill_manager.set_can_use_skill(true)
	#Remove the node from the scene so it doesn't interfere
	player_hitbox.queue_free()
	player.remove_child(self)
	#Delete the node
	queue_free()

func get_skill_type() ->String:
	return skill_type

func get_damage() -> int:
	return damage

func get_direction() -> Vector2:
	return direction

#Automatically cancel the skill when it ends
func hitbox_animation_finished(anim_name):
	cancel()
