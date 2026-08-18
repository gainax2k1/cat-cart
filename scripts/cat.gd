extends Node2D

@export var game: Node
@onready var _animated_sprite = $AnimatedSprite2D

const START_POS = Vector2(0,0)

#var charged_energy = 0.0
var distance_traveled = 0.0
var speed = 0.0

func _ready():
	# get ref from main game
	if not game:
		game = get_parent()	
	position = START_POS

func _process(delta: float):
	if game.is_moving:
		_animated_sprite.play("cat-bob")	

	if game.is_charging:
		_animated_sprite.play("cat-blink")
		
	game.update_cat_position(delta)
	game.update_ui()


	
