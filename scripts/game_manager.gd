extends Node

var max_meter = 100
var max_speed = 100 # maybe unneccessary? speed determined by meter...
var meter = 0 #starting charge
var is_charging = false
var is_moving = false
var distance_traveled = 0
var cat_speed = 0

@onready var cat = $cat
@onready var distance_label = $DistanceLabel

func _ready() -> void:
	# Set up meter? maybe only in update_ui

	# Set up input
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	#setup cat
	cat.connect("cat_stopped", _on_cat_stopped)
	is_charging = true
	
	# Update the UI
	update_ui()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		
		if $charge.pressed:
			print("charge button pressed.")
			charge_meter()
			return
			
		if $release.pressed:
			print("release button pressed.")
			release_cat()
			return

# delta is the elapsed time since the previous frame
func _process(delta: float) -> void:
	if is_moving:
		update_cat_position(delta)
		
		
func update_ui():
	# Add meter updates!
	
	distance_label.text = "Distance: " + str(int(distance_traveled))
	
func charge_meter():
	if is_charging and meter < max_meter:
		meter += 5
		if meter >= max_meter:
			meter = max_meter
			
		update_ui()

func _on_cat_stopped():
	print("_on_cat_stopped called")
	is_moving = false  # Update the is_moving variable

func release_cat():
	if not is_moving and meter > 0:
		is_moving = true
		is_charging = false
		
		# starting speed
		cat_speed = (meter / max_meter) * max_speed
		print("cat_speed" + cat_speed)
		
		cat.start_moving(cat_speed)


func update_cat_position(delta):
	if is_moving:
		cat.position += Vector2(cat_speed * delta, 0)
		distance_traveled += cat_speed * delta
		meter -= 1
		if meter < 0:
			meter = 0
		#adjust cat speed
		cat_speed = (meter / max_meter) * max_speed
		print("new cat_speed: " + cat_speed)
		update_ui()
