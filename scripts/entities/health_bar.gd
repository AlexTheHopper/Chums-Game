extends Node3D

@export var health_node: Node
@export var current_health_bar: MeshInstance3D
@export var max_health_bar: MeshInstance3D
@export var damaged_bar: MeshInstance3D
@export var notch_scene: PackedScene
@onready var damaged_timer: Timer = $DamagedTimer
@onready var animation_player: AnimationPlayer = $AnimationPlayer
var is_player := false

var health_ratio := 1.0
var damaged_health_ratio := 1.0
var is_shrinking := false
const NOTCH_INC: int = 50

func _ready() -> void:	
	#Connect to parent Health node to detect changed in health
	health_node.health_changed.connect(_on_health_changed)
	health_node.max_health_changed.connect(_on_max_health_changed)
	
	#Set initial values:
	_on_health_changed(0)
	_on_max_health_changed(0)
	
	set_notches()
	
	if owner is Player:
		is_player = true
		visible = false

func _physics_process(_delta: float) -> void:
	if not is_shrinking:
		return

	damaged_health_ratio = lerp(damaged_health_ratio, health_ratio, 0.1)
	damaged_bar.scale.x = damaged_health_ratio
	damaged_bar.position.x = (damaged_health_ratio - 1) * 0.5

	if abs(damaged_health_ratio - health_ratio) < 0.01:
		is_shrinking = false
		damaged_bar.visible = false
		
		if is_player:
			animation_player.play("fade_out")


func set_notches():
	#Add notches
	var max_health = health_node.max_health
	if max_health >= NOTCH_INC:
		var notch_count = floor(1.0 * health_node.max_health / NOTCH_INC) + 1
		var bar_length = current_health_bar.mesh.size.x
		var start_x = -0.5 * bar_length
				
		for n in range(notch_count):
			var notch = notch_scene.instantiate()
			max_health_bar.add_child(notch)
			
			#Position notch correctly
			var extra_x: float = ((1.0 * n * NOTCH_INC) / health_node.max_health) * bar_length
			notch.position = Vector3(start_x + extra_x, 0, 0)
	
func _on_health_changed(_difference):
	health_ratio = max(1.0 * health_node.health / health_node.max_health, 0.0)
	
	current_health_bar.scale.x = health_ratio
	current_health_bar.position.x = (health_ratio - 1) * 0.5

	damaged_timer.start() #This also resets the time, wait to start decreasing damaged part.
	if not is_equal_approx(health_ratio, damaged_health_ratio):
		damaged_bar.visible = true

	#Adjust colour:
	var health_color = Color(1.0 - health_ratio, health_ratio, 0.0)
	if health_ratio <= 0.0:
		health_color = Color(0.0, 0.0, 0.0, 1.0)
	current_health_bar.mesh.material.albedo_color = health_color
	
	if is_player and not visible:
		animation_player.play("fade_in")
	
func _on_max_health_changed(_difference):
	#Reset notches:
	for notch in max_health_bar.get_children():
		notch.queue_free()
	set_notches()
	
	health_ratio = max(1.0 * health_node.health / health_node.max_health, 0.0)
	damaged_health_ratio = health_ratio

func override_ratio(value: float) -> void:
	damaged_health_ratio = value
	damaged_bar.scale.x = damaged_health_ratio
	damaged_bar.position.x = (damaged_health_ratio - 1) * 0.5


func _on_damaged_timer_timeout() -> void:
	is_shrinking = true
