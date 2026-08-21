extends Node

var record_score = 0
var total_score_counter = 0

var max_meter = 50
var meter = 0.0 #starting charge
var meter_drain_rate = 10
var meter_ticker = 0.0

var speed_drain_rate = .9
var start_speed = 0
var speed_ticker = 0.0

var is_charging = false
var is_moving = false
var delta_cat = 0.0 #change in cat position in pixels (cat.speed * delta)

@onready var cat = $cat
@onready var distance_label = $cat/Camera2D/DistanceLabel
@onready var charge_label = $cat/Camera2D/ChargeLabel
@onready var record_label = $cat/Camera2D/RecordLabel

var unlock_thresholds = [0, 1500, 5000, 10000]
var unlocks = {
	"Meter Lvl.": [50, 75, 100, 125],
	"Drain Lvl.": [10, 9, 8, 7],
	}

func _ready() -> void:
	# Set up input, needs work, pointer not visible?
	
	#Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	is_charging = true
	is_moving = false
	#check_unlocks()
	update_ui()

func _on_charge_pressed():
	if is_charging:
		print("charging! ->" + str(meter))
		meter += 5
		if meter >= max_meter:
			meter = max_meter
		update_ui()

func _on_release_pressed():
	print("release button pressed.")
	cat._animated_sprite.play("cat-bob")
	release_cat()

func _on_reset_pressed():
	total_score_counter += cat.distance_traveled
	cat.position = cat.START_POS
	cat.distance_traveled = 0.0
	meter = 0.0
	is_charging = true
	is_moving = false
	cat._animated_sprite.play("cat-blink")
	check_unlocks()
	update_ui()
	

func _phyiscs_process(delta: float) -> void:
	update_cat_position(delta)	
	update_ui()
	
func update_ui():
	charge_label.text = "Charge amount: " + str(int(meter)) + "/" + str(max_meter)
	distance_label.text = "Distance: " + str(int(cat.distance_traveled))
	record_label.text = "Record: " + str(int(record_score))

func release_cat():
	is_charging = false
	cat.speed = meter
	speed_ticker = 1 #so cat starts at speed
	print("cat_speed in release: " + str(cat.speed))
	update_ui()
	
func drain_meter(delta):
	meter_ticker += delta
	if meter_ticker >= 1:
		meter_ticker = 0
		if meter > 1:
			meter = meter - meter_drain_rate
		if meter <= 1:
			meter = 0
		
func drain_speed(delta):	
	if not is_charging:
		if meter > 0:
			speed_ticker += delta
			if speed_ticker >= 1:
				cat.speed = (cat.speed + meter) * speed_drain_rate
		else:
			cat.speed = 0
			is_moving = false
		
	
func update_cat_position(delta):
	if cat.distance_traveled > record_score:
		record_score = cat.distance_traveled
	drain_meter(delta)
	if not is_charging:
		drain_speed(delta)	
		print("new cat_speed: " + str(cat.speed))		
		print("delta in update_Cat_position: " + str(delta))
		delta_cat = cat.speed * delta
		if delta_cat < .01:
			delta_cat = 0.0
			is_moving = false
			cat._animated_sprite.play("cat-blink")
		print("delta_cat: " + str(delta_cat))
		
		cat.position += Vector2(delta_cat, 0)
		cat.distance_traveled += delta_cat
			
	update_ui()

func check_unlocks():
	var mtr_vals = 0
	var dr_vals = 0
	
	for lock_lvl in len(unlock_thresholds):	
		if not total_score_counter > unlock_thresholds[lock_lvl]:
			print("total distance: " + str(total_score_counter))
			print("lock_lvl is:" + str(lock_lvl) + " Threshold: " + str(unlock_thresholds[lock_lvl]))
			mtr_vals = unlocks["Meter Lvl."]
			print("mtr_vals: " + str(mtr_vals))
			print("mtr_vals[lock_lvl]: " + str(mtr_vals[lock_lvl]))
			max_meter = mtr_vals[lock_lvl]
			
			dr_vals = unlocks["Drain Lvl."]
			print("dr_Vals: " + str(dr_vals))
			print("dr_vals[lock_lvl]: " + str(dr_vals[lock_lvl]) )
			meter_drain_rate = dr_vals[lock_lvl]
			
			for unlock in unlocks:
				print("Level: " + str(lock_lvl) + " " + unlock + str(unlocks[unlock][lock_lvl]))
			
			return
	
