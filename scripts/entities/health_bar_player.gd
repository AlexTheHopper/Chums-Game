extends Control

@onready var health_bar := $Health

@onready var tick_zero := $TickZero

@onready var length_zero: float
@onready var health := 0.0
@onready var max_health := 1.0


func _ready() -> void:
	length_zero = health_bar.size.x
	
func set_max_health(value):
	max_health = value
	
	set_health(health)
	set_ticks()

func set_health(value):
	health = value
	var health_ratio = health / max_health
	var new_x = health_ratio * length_zero
	health_bar.set_deferred("size", Vector2(new_x, health_bar.size.y))
	health_bar.color = Color((1.0 - health_ratio) * 0.8, health_ratio * 0.5, 0.0)

func set_ticks():
	for tick in $Ticks.get_children():
		tick.queue_free()
	
	var tick_spacing_ratio = (5.0 / max_health)
	
	for n in range(1, floor(max_health / 5) + 1):
		var tick = tick_zero.duplicate()
		
		tick.position = Vector2(n * tick_spacing_ratio * health_bar.size.x, 0)
		add_child(tick)
