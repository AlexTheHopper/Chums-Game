extends Control

@onready var health_bar: ColorRect = $Health
@onready var damaged_bar: ColorRect = $Damaged
@onready var tick_zero := $Ticks/TickZero
@onready var length_zero: float
@onready var posx_zero = health_bar.position.x
@onready var health := 0.0
@onready var max_health := 1.0
@onready var damaged_timer: Timer = $DamagedTimer


var is_shrinking := false
var health_ratio := 1.0
var damaged_health_ratio := 1.0


func _ready() -> void:
	length_zero = health_bar.size.x

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
	for tick in $Ticks.get_children().slice(1, $Ticks.get_children().size()):
		tick.queue_free()
	
	var tick_spacing_ratio = (50.0 / max_health)
	
	for n in range(1, floor(max_health / 50.0) + 1):
		var tick = tick_zero.duplicate()
		var xpos = round((n * tick_spacing_ratio * self.size.x) + posx_zero)
		tick.global_position = Vector2(xpos, 0)
		$Ticks.add_child(tick)


func _on_damaged_timer_timeout() -> void:
	is_shrinking = true
