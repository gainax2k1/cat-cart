extends Node2D

@export var game: Node

var cat_speed = 0

signal cat_stopped

func _ready():
	# get ref from main game
	if not game:
		game = get_parent()
	
	# set starting position
	position = Vector2(0,0)

func start_moving(initial_speed):
	print("start_moving: " + initial_speed)
	cat_speed = initial_speed

# cat movement
func _process(delta: float):
	if cat_speed > 0:
		print("cat speed: " + cat_speed)
		global_position.x += cat_speed * delta
		
		#update dist traveled
		if game:
			game.distance_traveled += cat_speed * delta
			#check for stopped
			if cat_speed <= 0:
				print("cat stopped")
				emit_signal("cat_stopped")
				
