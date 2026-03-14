extends Node3D
class_name Credits

var credits_done := true

@onready var camera: Camera3D = $Camera3D
@onready var entities: Node3D = $Entities

signal return_to_main_menu

func _ready() -> void:
	Global.game_begun = false
	return_to_main_menu.connect(Global.restart_game)
	
	if PlayerStats.player_total_damage_taken == 0:
		PlayerStats.attempt_achievement_unlock(PlayerStats.ACHIEVEMENTS.ACH_ON_WIN_NO_DAMAGE)

func spawn_chum(chum_id: int, location: Vector3, angle: float) -> void:
	var chum_to_spawn = ChumsManager.get_specific_chum_id(chum_id)
	if not chum_to_spawn:
		return
	#Spawns chum
	var chum_instance = chum_to_spawn.instantiate()
	entities.add_child(chum_instance)
	chum_instance.global_position = location + Vector3(3.0 * sin(angle), 0.0, 3.0 * cos(angle))
	chum_instance.generalchumbehaviour.visible = false
	chum_instance.sleep_zone.queue_free()
	chum_instance.rotation.y = randf_range(0, 2*PI)
	chum_instance.scale = Vector3(1.5, 1.5, 1.5)
	chum_instance.anim_player.play("Idle")
	chum_instance.anim_player.speed_scale = randf_range(0.8, 1.2)

func exit_credits() -> void:
	await get_tree().create_timer(2.5).timeout
	TransitionScreen.transition(3)
	await TransitionScreen.on_transition_finished
	return_to_main_menu.emit(false, false)
	queue_free()
