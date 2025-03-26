extends Node3D

@export var particle_count: int = -1
@onready var particles := $CPUParticles3D

func _ready() -> void:
	if particle_count < 0:
		var dist_from_lobby = Global.world_map[Global.room_location]["value"]
		particle_count = int(Functions.map_range(dist_from_lobby, Vector2(1, Global.map_size), Vector2(100, 250)))
	particles.amount = particle_count
