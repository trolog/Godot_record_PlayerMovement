extends KinematicBody2D

export var gravity = 1500
export var acceleration = 2000
export var deacceleration = 2000
export var friction = 2000
export var current_friction = 2000
export var max_horizontal_speed = 400
export var max_fall_speed = 1000
export var jump_height = -600

var vSpeed = 0
var hSpeed = 0

var count = 0

#Our dictionary we store values too
var save_data = {"0": ["nothing",Vector2(0,0),false]}

var motion = Vector2.ZERO
var UP : Vector2 = Vector2(0,-1)

onready var ani = $AnimatedSprite
onready var ground_ray = $ground_ray


func _ready():
	var file_check = File.new()
	if(file_check.file_exists("res://ghosts/" + get_tree().current_scene.name + ".json")):
		var ghost = preload("res://objects/player_ghost.tscn")
		var load_ghost = ghost.instance()
		load_ghost.global_position = self.global_position
		get_parent().call_deferred("add_child",load_ghost)
		
func do_record():
	count += 1
	save_data[String(count)] = [ani.animation,global_position,ani.flip_h]

	if(Input.is_action_just_pressed("ui_down")):
		var f := File.new()
		f.open("res://ghosts/" + get_tree().current_scene.name + ".json", File.WRITE)
		prints("Saving to", f.get_path_absolute())
		f.store_string(JSON.print(save_data))
		f.close()
	
func _physics_process(delta):
	do_record()
	
	check_ground_logic()
	handle_movement(delta)
	do_physics(delta)
	pass
		
func check_ground_logic():
	pass
	
func do_physics(delta):
	if(is_on_ceiling()):
		motion.y = 10
		vSpeed = 10
		
	vSpeed += (gravity * delta) # apply gravity downwards
	vSpeed = min(vSpeed,max_fall_speed) # limit how fast we can fall
	
	#update our motion vector
	motion.y = vSpeed
	motion.x = hSpeed
	
	#apply our motion vectgor to move and slide
	motion = move_and_slide(motion,UP)
	
	pass
	
func handle_movement(var delta):
	if(is_on_wall()):
		hSpeed = 0
		motion.x = 0
	if(ground_ray.is_colliding()):
		vSpeed = 0
		motion.y = 0
	else:
		ani.play("JUMP")
	#controller right/keyboard right
	if(Input.get_joy_axis(0,0) > 0.3 or Input.is_action_pressed("ui_right")):
		if(hSpeed <-100):
			hSpeed += (deacceleration * delta)
			#if(touching_ground):
		#		ani.play("TURN")
		elif(hSpeed < max_horizontal_speed):
			hSpeed += (acceleration * delta)
			ani.flip_h = false
			if(ground_ray.is_colliding()):
				ani.play("RUN")
		else:
			if(ground_ray.is_colliding()):
				ani.play("RUN")
	elif(Input.get_joy_axis(0,0) < -0.3 or Input.is_action_pressed("ui_left")):
		if(hSpeed > 100):
			hSpeed -= (deacceleration * delta)
			#if(touching_ground):
		#		ani.play("TURN")
		elif(hSpeed > -max_horizontal_speed):
			hSpeed -= (acceleration * delta)
			ani.flip_h = true
			if(ground_ray.is_colliding()):
				ani.play("RUN")
		else:
			if(ground_ray.is_colliding()):
				ani.play("RUN")
	else:
		if(ground_ray.is_colliding()):
			ani.play("IDLE")
		hSpeed -= min(abs(hSpeed),current_friction * delta) * sign(hSpeed)
		
	if(ground_ray.is_colliding()):
		if(Input.is_action_just_pressed("ui_accept")):
			vSpeed = jump_height
	pass

