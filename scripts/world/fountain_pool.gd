extends Node3D

@onready var heart_tscn := load("res://scenes/entities/heart_item.tscn")
var heart_num := -1
var hearts_set := false
var active := false

const HEART_DIST := 4.0
const HEART_HEAL := 20

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
		$Hearts.add_child(heart_inst)
		

func _physics_process(delta: float) -> void:
	$Hearts.rotation.y += delta / 2

func _on_heal_zone_body_entered(body: Node3D) -> void:
	#Remove a visual heart and heal body if body has damage:
	if len($Hearts.get_children()) > 0 and body.has_damage() and active:
		$Hearts.get_children().pick_random().remove()
		Global.world_map[Global.room_location]["item_count"] -= 1
		heart_num -= 1
		body.health_node.health += HEART_HEAL
		active = false
		$Timer.start()


func _on_fly_zone_body_entered(body: Node3D) -> void:
	var angle: float = Functions.angle_to_xz(self, body)
	var vel_2d: Vector2 = Vector2(sin(angle), cos(angle)) * 7.5
	
	body.velocity = Vector3(vel_2d.x, 25.0, vel_2d.y)
	body.is_launched = true


func _on_timer_timeout() -> void:
	active = true
