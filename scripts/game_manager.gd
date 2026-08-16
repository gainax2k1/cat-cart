extends Node

var max_meter = 100
var meter = 0.0 #starting charge
var ratio = 0.9 # was "meter / max_meter" trying fixed ratio instead
var meter_drain_rate =  1

var start_speed = 10000 # maybe unneccessary? speed determined by meter...

var is_charging = false
var is_moving = false

var delta_cat = 0.0 #cat.speed * delta #bad to use delta here?
	

#var distance_traveled = 0.0 #moved to cat.gd
#var cat_speed = 0.0 #moved to cat.gd
	

@onready var cat = $cat
@onready var distance_label = $cat/Camera2D/DistanceLabel
@onready var charge_label = $cat/Camera2D/ChargeLabel

func _ready() -> void:
	# Set up meter? maybe only in update_ui
	
	
	# Set up input
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	#setup cat
	#cat.connect("cat_stopped", _on_cat_stopped)
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

# delta is the elapsed time since the previous frame
func _phyiscs_process(delta: float) -> void:
	#Engine.time_scale = 0.9 #adjusts engine, might be "hacky"?
	drain_meter(delta)
	update_cat_position(delta)	
	update_ui()
	
func update_ui():
	charge_label.text = "Charge: " + str(int(meter)) + "/" + str(max_meter)
	distance_label.text = "Distance: " + str(int(cat.distance_traveled))
	# update_cat_position(get_physics_process_delta_time()) #why is this here?
	
func charge_meter():
	if is_charging:
		print("charging! ->" + str(meter))
		meter += 5
		if meter >= max_meter:
			meter = max_meter
		update_ui()
	
func drain_meter(delta):
	if meter > 0:
		meter -= delta * ratio
		if meter < 0:
			meter = 0
	ratio = meter/max_meter
	
func release_cat():
	is_charging = false
	is_moving = true
	# starting speed
	cat.speed = start_speed
	#sratio = meter / max_meter #maybe not here? where to adjust meter drain...
	print("cat_speed in release: " + str(cat.speed))
	#update_cat_position(delta)
	update_ui()
	
func update_cat_position(delta):
	#maybe implement tick logic? (tick += delta, if tick = 1....)
	
	print("new cat_speed: " + str(cat.speed))

	if cat.speed <= 0:
		is_moving = false
	
	print("delta in update_Cat_position: " + str(delta))
	delta_cat = cat.speed * delta #bad to use delta here?
	print("delta_cat: " + str(delta_cat))
	
	cat.position += Vector2(delta_cat, 0)
	cat.distance_traveled += cat.speed * delta
	
	update_ui()
