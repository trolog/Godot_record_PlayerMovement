extends KinematicBody2D


var load_data : Dictionary = Dictionary()
var count = 0

onready var ani = $AnimatedSprite

func _ready():
	load_data = load_file()

func load_file():
	var f := File.new()
	f.open("res://ghosts/" + get_tree().current_scene.name +".json", File.READ)
	var result := JSON.parse(f.get_as_text())
	f.close()
	return result.result as Dictionary
	
func _physics_process(delta):
	get_recording()
	pass
	
func get_recording():
	count += 1
	var test = load_data.get(String(count))
	if(test != null):
		print(test[1])
		ani.play(test[0])
		global_position = str2var("Vector2" + test[1])
		ani.flip_h = test[2]
	
	
