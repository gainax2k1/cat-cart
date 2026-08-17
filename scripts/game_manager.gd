extends Node

var max_meter = 100
var meter = 0.0 #starting charge
var meter_drain_rate = .5
var speed_drain_rate = .5
var start_speed = 100 

var is_charging = false
var is_moving = false
var delta_cat = 0.0 #change in cat position in pixels (cat.speed * delta)

@onready var cat = $cat
@onready var distance_label = $cat/Camera2D/DistanceLabel
@onready var charge_label = $cat/Camera2D/ChargeLabel

func _ready() -> void:
	# Set up input, needs work, pointer not visible?
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	is_charging = true
	is_moving = false
	
	update_ui()

func _on_charge_pressed():
	if not is_moving:
		print("charge button pressed.")
		charge_meter()
	return

func _on_release_pressed():
	print("release button pressed.")
	release_cat()
	return

func _phyiscs_process(delta: float) -> void:
	update_cat_position(delta)	
	update_ui()
	
func update_ui():
	charge_label.text = "Charge: " + str(int(meter)) + "/" + str(max_meter)
	distance_label.text = "Distance: " + str(int(cat.distance_traveled))

func release_cat():
	is_charging = false
	is_moving = true

	cat.speed = start_speed
	print("cat_speed in release: " + str(cat.speed))
	update_ui()
		
func charge_meter():
	if is_charging:
		print("charging! ->" + str(meter))
		meter += 5
		if meter >= max_meter:
			meter = max_meter
		update_ui()
	
func drain_meter(delta):
	if meter > 0:
		meter = meter - (meter * meter_drain_rate * delta) #delta...?
	if meter <= 0:
		meter = 0
	
func drain_speed(delta):
	if not is_charging and cat.speed > 0:
		is_moving = true
		cat.speed = cat.speed - (cat.speed * speed_drain_rate * delta)
	else:
		is_moving = false
		cat.speed = 0
	
func update_cat_position(delta):
	drain_meter(delta)
	if not is_charging:
		drain_speed(delta)	
		print("new cat_speed: " + str(cat.speed))		
		print("delta in update_Cat_position: " + str(delta))
		delta_cat = cat.speed * delta
		if delta_cat < .01:
			delta_cat = 0.0
			is_moving = false
		print("delta_cat: " + str(delta_cat))
		
		cat.position += Vector2(delta_cat, 0)
		cat.distance_traveled += delta_cat
			
	update_ui()
