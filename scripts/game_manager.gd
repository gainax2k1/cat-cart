extends Node

const METER_COLOR = Color(1.0, 0.0, 1.0, 1.0)
const BACKGROUND_COLOR = Color(0.247, 0.468, 1.0, 1.0)
const TRACK_COLOR = Color(0.0, 0.706, 0.0, 1.0)

var meter_height = 40 #?
const METER_WIDTH = 60 #?
const METER_MARGIN = 20 #?

var max_meter = 100
var max_speed = 100 # maybe unneccessary? speed determined by meter...
var meter = 0 #starting charge
var is_charging = false
var is_moving = false
var distance_traveled = 0
var cat_speed = 0

signal cat_stopped


# Cat ref
@onready var cat = $cat

# UI elements
@onready var meter_background = $MeterBackground
@onready var meter_fill = $MeterFill
@onready var distance_label = $DistanceLabel


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Set up meter
	#meter_background.rect
	#meter_background.rect_min_size = Vector2(METER_WIDTH, meter_height)
	#meter_fill.rect_min_size = Vector2(0, meter_height)
	
	# Set up input
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	#setup cat
	
	#cat.connect("cat_stopped", self, "_on_cat_stopped")
	
		
	# Start charging
	is_charging = true
	
	# Update the UI
	update_ui()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		var mouse_pos = event.position
	
		# Check if the meter area was clicked to charge
		var meter_rect = Rect2(METER_MARGIN, 200, METER_WIDTH, meter_height)
		if meter_rect.has_point(mouse_pos):
			charge_meter()
			return
			
		# Check if the car was clicked to release
		
		if cat.get_global_rect().has_point(mouse_pos):
			release_cat()
			return




# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if is_moving:
		update_cat_position(delta)
		
		
func update_ui():
	# Update meter fill
	meter_fill.modulate = METER_COLOR
	meter_fill.scale = Vector2(meter, 1)
	
	# Update distance label
	distance_label.text = "Distance: " + str(int(distance_traveled)) + " px"
	
	# Update charging state text
	if is_charging:
		distance_label.text = "Distance: " + str(int(distance_traveled)) + " px"
	else:
		distance_label.text = "Distance: " + str(int(distance_traveled)) + " px - Meter: " + str(int(meter)) + "%"

func charge_meter():
	if is_charging and meter < max_meter:
		meter += 5
		if meter >= max_meter:
			meter = max_meter
			
		update_ui()
		cat.update_cat_ui()

func _on_cat_stopped():
	is_moving = false  # Update the is_moving variable

func release_cat():
	if not is_moving and meter > 0:
		is_moving = true
		is_charging = false
		
		# Calculate initial speed based on meter percentage
		cat_speed = (meter / max_meter) * max_speed
		
		# Start the car moving
		cat.start_moving(cat_speed)


func update_cat_position(delta):
	if is_moving:
		# Move the car
		var new_position = cat.position + Vector2(cat_speed * delta, 0)
		
		# Check if the car is out of bounds
		var screen_width = 10000 #MAGIC IS BAD!! TESTING FOR END OF ROAD
		
		if new_position.x > screen_width:
			is_moving = false
			is_charging = true
			cat_speed = 0
			distance_traveled += (new_position.x - cat.position.x)
			update_ui()
			return	
				
		cat.position = new_position
		distance_traveled += cat_speed * delta
			
			# Gradually decrease the meter
		meter -= 1
		if meter < 0:
			meter = 0
		
		# Recalculate speed based on remaining meter
		cat_speed = (meter / max_meter) * max_speed
			
		# Update the UI
		update_ui()
		cat.update_cat_ui()
