extends Node
class_name Health

signal max_health_changed(attack: int)
signal health_changed(attack: int)
signal health_depleted

@export var immune: bool = true : set = set_immune, get = get_immune
var immune_timer: Timer = null
var health_initialised := false
var damage_grace_time := 0.15

var max_health: int = 1 : set = set_max_health, get = get_max_health
var health : int = 1 : set = set_health, get = get_health

func set_max_health(value: int):
	var clamped_value = 1 if value <= 0 else value
	if not clamped_value == max_health:
		var difference = clamped_value - max_health
		max_health = clamped_value
		
		if health > max_health:
			health = max_health
		else:
			health += difference
			
		max_health_changed.emit(difference)
		
func set_max_health_override(value: int):
	max_health = value
		
func get_max_health() -> int:
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
	
func set_health(value: int):
	if value < health and immune:
		return
		
	var clamped_value = clampi(value, 0, max_health)
	
	#Grace period
	if clamped_value < health:
		set_temporary_immune(damage_grace_time)
	
	if clamped_value != health:
		var difference = clamped_value - health
		health = clamped_value
		
		if health <= 0:
			health = 0
			health_depleted.emit()
			
		health_changed.emit(difference)

	health_initialised = true
	
func set_health_override(value: int):
	health = value
	
func get_health() -> int:
	return health
