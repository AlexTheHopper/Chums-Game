extends StaticBody3D

@export var is_permanent := false

var wobble_angle := Vector3.ZERO
var wobble_velocity := Vector3.ZERO
var damping := 0.5
var stiffness := 10.0

func _ready() -> void:
	#Remove if have entered close room
	if Global.game_begun and not is_permanent:
		var _axis: String = "x"
		var _sign: String = "pos"
		if abs(global_position.x) < abs(global_position.z):
			_axis = "z"
		if global_position.x + global_position.z < 0.0:
			_sign = "neg"
		
		if Global.world_map[Global.room_location]["has_%s_%s" % [_axis, _sign]]:
			var dir_vec = Vector2i((1 if _axis == "x" else 0) * (1 if _sign == "pos" else -1), (1 if _axis == "z" else 0) * (1 if _sign == "pos" else -1))
			if Global.world_map[Global.room_location + dir_vec]["entered"]:
				queue_free()
		else:
			queue_free()
	rotation.y += randf_range(-PI/8, PI/8)
	
	#Shake when player is hit:
	if Global.game_begun:
		get_tree().get_first_node_in_group("Player").health_node.health_changed.connect(_on_player_damaged)

	
func _physics_process(delta: float) -> void:
	var restoring_force = -wobble_angle * stiffness
	wobble_velocity += restoring_force * delta
	wobble_velocity *= exp(-damping * delta)
	wobble_angle += wobble_velocity * delta
	
	#To account for initial scene rotation:
	#wobble_angle = wobble_angle.rotated(Vector3(0, 1, 0), rotation_degrees.y)

	rotation_degrees.x = wobble_angle.x
	rotation_degrees.z = wobble_angle.z

func _on_area_3d_area_entered(area: Area3D) -> void:
	if area is Hitbox:
		var dir = Functions.vector_to_normalized(area, self)
		wobble_velocity += 3 * Vector3(dir.z * area.damage, 0, -dir.x * area.damage).rotated(Vector3.UP, -rotation.y)
		
		AudioManager.create_3d_audio_at_location(self.global_position, SoundEffect.SOUND_EFFECT_TYPE.ON_PLAYER_HURT)

func _on_player_damaged(difference) -> void:
	if difference < 0:
		wobble_velocity += 3 * difference * Vector3(1, 0, 0).rotated(Vector3.UP, randf_range(0, 2*PI))
