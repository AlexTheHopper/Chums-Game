extends Control

@onready var health_bar: ColorRect = $Health
@onready var damaged_bar: ColorRect = $Damaged
@onready var tick_zero := $TickZero
@onready var length_zero := health_bar.size.x + 2.0 #Width of tick
@onready var health := 0.0
@onready var max_health := 1.0
@onready var damaged_timer: Timer = $DamagedTimer


var is_shrinking := false
var health_ratio := 1.0
var damaged_health_ratio := 1.0

func _physics_process(_delta: float) -> void:
	if not is_shrinking:
		return

	damaged_health_ratio = lerp(damaged_health_ratio, health_ratio, 0.1)
	var new_x_damage = damaged_health_ratio * length_zero
	damaged_bar.set_deferred("size", Vector2(new_x_damage, health_bar.size.y))
	if abs(damaged_health_ratio - health_ratio) < 0.01:
		is_shrinking = false
		damaged_bar.visible = false

func set_max_health(value):
	max_health = value
	
	set_health(health)
	set_ticks()

func set_health(value):
	health = value
	health_ratio = health / max_health
	var new_x_health = health_ratio * length_zero
	health_bar.set_deferred("size", Vector2(new_x_health, health_bar.size.y))
	health_bar.color = Color((1.0 - health_ratio) * 0.8, health_ratio * 0.5, 0.0)
	
	damaged_timer.start() #This also resets the time, wait to start decreasing damaged part.
	if not is_equal_approx(health_ratio, damaged_health_ratio):
		damaged_bar.visible = true

func set_ticks():
	for tick in $Ticks.get_children():
		tick.queue_free()

	var tick_count = floor(max_health / 50.1)
	for tick_n in range(tick_count):
		var tick = tick_zero.duplicate()
		tick.visible = true
		$Ticks.add_child(tick)
		tick.position.x = Functions.map_range((tick_n + 1) * 50, Vector2(0, max_health), Vector2(3.0, 122.0))

func _on_damaged_timer_timeout() -> void:
	is_shrinking = true
