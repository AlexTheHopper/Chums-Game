extends Node3D

@onready var item_tscn := load("res://scenes/entities/upgrade_item.tscn")
var item_num := -1
var items_set := false
var active := false

const ITEM_DIST := 4.0
const ITEM_HEAL := 20

func _ready() -> void:
	if not items_set:
		item_num = Global.world_map[Global.room_location]["item_count"]
		
	if item_num <= 0:
		return
		
	for i in item_num:
		var angle = Functions.map_range(i, Vector2(0, item_num), Vector2(0, 2*PI))
		var x := ITEM_DIST * cos(angle)
		var z := ITEM_DIST * sin(angle)
		
		var item_inst = item_tscn.instantiate()
		item_inst.position = Vector3(x, 2, z)
		$Items.add_child(item_inst)
		

func _physics_process(delta: float) -> void:
	$Items.rotation.y += delta / 2

func _on_active_zone_body_entered(body: Node3D) -> void:
	#Remove a visual heart and heal body if body has damage:
	if len($Items.get_children()) > 0 and active:
		$Items.get_children().pick_random().remove()
		Global.world_map[Global.room_location]["item_count"] -= 1
		item_num -= 1
		active = false
		$Timer.start()
		
		if body is Player:
			body.increase_attack(10) #Increase base damage by x and extra damage by int(x/2)
		elif body is Chum:
			body.increase_stats(0.1) #Increase all stats by base * x


func _on_fly_zone_body_entered(body: Node3D) -> void:
	var angle: float = Functions.angle_to_xz(self, body)
	var vel_2d: Vector2 = Vector2(sin(angle), cos(angle)) * 7.5
	
	body.velocity = Vector3(vel_2d.x, 25.0, vel_2d.y)
	body.is_launched = true


func _on_timer_timeout() -> void:
	active = true
