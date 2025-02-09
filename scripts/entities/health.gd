extends Node
class_name Health

signal max_health_changed(attack: float)
signal health_changed(attack: float)
signal health_depleted

@export var max_health: float : set = set_max_health, get = get_max_health
@export var immune: bool = true : set = set_immune, get = get_immune
var immune_timer: Timer = null

@onready var health := max_health : set = set_health, get = get_health

func set_max_health(value: float):
	var clamped_value = 1.0 if value <= 0.0 else value
	if not clamped_value == max_health:
		var difference = clamped_value - max_health
		max_health = value
		max_health_changed.emit(difference)
		
		if health > max_health:
			health = max_health
		
func get_max_health() -> float:
	return max_health


func set_immune(value: bool):
	immune = value
	
func get_immune() -> bool:
	return immune
	
func set_temporary_immune(time: float):
	if immune_timer == null:
		immune_timer = Timer.new()
		immune_timer.one_shot = true
		add_child(immune_timer)
		
	if immune_timer.timeout.is_connected(set_immune):
		immune_timer.timeout.disconnect(set_immune)
		
	immune_timer.set_wait_time(time)
	immune_timer.timeout.connect(set_immune.bind(false))
	immune = true
	immune_timer.start()
	
	
func set_health(value: float):
	if value < health and immune:
		return
		
	var clamped_value = clampf(value, 0, max_health)
	
	if not clamped_value == health:
		var difference = clamped_value - health
		health = value
		health_changed.emit(difference)
		
		if health == 0:
			health_depleted.emit()
	
func get_health() -> float:
	return health
