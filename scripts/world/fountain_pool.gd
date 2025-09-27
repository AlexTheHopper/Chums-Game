extends Node3D

@onready var heart_tscn := load("res://scenes/entities/heart_item.tscn")
@onready var hearts: Node3D = $Hearts
@onready var hearts_timer: Timer = $Timer

var heart_num := -1
var hearts_set := false
var active := false

const HEART_DIST := 4.0
const HEART_HEAL_FACTOR := 0.1
const HEART_HEAL_MIN := 25.0

func _ready() -> void:
	if not hearts_set:
		heart_num = Global.world_map[Global.room_location]["item_count"]
		
	if heart_num <= 0:
		return
		
	for i in heart_num:
		var angle = Functions.map_range(i, Vector2(0, heart_num), Vector2(0, 2*PI))
		var x := HEART_DIST * cos(angle)
		var z := HEART_DIST * sin(angle)
		
		var heart_inst = heart_tscn.instantiate()
		heart_inst.position = Vector3(x, 2, z)
		hearts.add_child(heart_inst)
		

func _physics_process(delta: float) -> void:
	hearts.rotation.y += delta / 2

func _on_heal_zone_body_entered(body: Node3D) -> void:
	#Remove a visual heart and heal body if body has damage:
	if len(hearts.get_children()) > 0 and body.has_damage() and active:
		hearts.get_children().pick_random().remove()
		Global.world_map[Global.room_location]["item_count"] -= 1
		heart_num -= 1
		body.health_node.health += max(body.health_node.max_health * HEART_HEAL_FACTOR, HEART_HEAL_MIN)
		active = false
		hearts_timer.start()
		
		if heart_num <= 0:
			Global.world_map[Global.room_location]["activated"] = true
			Global.world_map_guide["fountain"] = Functions.astar2d(Global.world_grid, 3, true)


func _on_fly_zone_body_entered(body: Node3D) -> void:
	var angle: float = Functions.angle_to_xz(self, body)
	var vel_2d: Vector2 = Vector2(sin(angle), cos(angle)) * 7.5
	
	body.velocity = Vector3(vel_2d.x, 25.0, vel_2d.y)
	body.is_launched = true


func _on_timer_timeout() -> void:
	active = true
