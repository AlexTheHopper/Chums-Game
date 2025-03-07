extends Node3D

@onready var heart_tscn := load("res://scenes/entities/heart.tscn")
var heart_num := -1
var hearts_set := false
var active := false

const HEART_DIST := 4.0
const HEART_HEAL := 5.0

func _ready() -> void:
	if not hearts_set:
		heart_num = Global.world_map[Global.room_location]["heart_count"]
		
	if heart_num <= 0:
		return
		
	for i in heart_num:
		var angle = Functions.map_range(i, Vector2(0, heart_num), Vector2(0, 2*PI))
		var x := HEART_DIST * cos(angle)
		var z := HEART_DIST * sin(angle)
		
		var heart_inst = heart_tscn.instantiate()
		heart_inst.position = Vector3(x, 2, z)
		$Hearts.add_child(heart_inst)
		

func _physics_process(delta: float) -> void:
	$Hearts.rotation.y += delta / 2

func _on_heal_zone_body_entered(body: Node3D) -> void:
	
	#Remove a visual heart and heal body if body has damage:
	if len($Hearts.get_children()) > 0 and body.has_damage() and active:
		$Hearts.get_children().pick_random().remove()
		Global.world_map[Global.room_location]["heart_count"] -= 1
		body.health_node.health += HEART_HEAL


func _on_fly_zone_body_entered(body: Node3D) -> void:
	var pos = body.global_position - Vector3(1.0, 0, 1.0)
	var x = pos.x + (5.0 if pos.x > 0 else -5.0)
	var y = 25.0
	var z = pos.z + (5.0 if pos.z > 0 else -5.0)
	body.velocity = Vector3(x, y, z)
	body.is_launched = true


func _on_timer_timeout() -> void:
	active = true
