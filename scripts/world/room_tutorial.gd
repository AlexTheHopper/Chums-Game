extends room
class_name tutorial_room

const TYPE := "tutorial"

func _ready() -> void:
	$RoomActivator.activate_bell.connect(close_doors)
	move_player_and_camera($PlayerSpawn.global_position)
	set_chums_loc_on_entry()
	
	for entity in $Entities.get_children():
		if entity is Chum:
			entity.spawn_currency.connect(spawn_currency)
	
	#Rotate all trees and grasses (I cant be bothered doing this manually they can be random)
	for deco in $Decorations/Large.get_children():
		deco.rotation.y = [0.0, PI / 2, PI, 3 * PI / 2].pick_random()
	for deco in $Decorations/Small.get_children():
		deco.rotation.y = [0.0, PI / 2, PI, 3 * PI / 2].pick_random()
#func load_room() -> void:
	#pass
#
#func decorate() -> void:
	#pass
#
#func fill_tunnels() -> void:
	#pass
#
#func set_player_loc_on_entry() -> void:
	#pass
#
#func set_chums_loc_on_entry() -> void:
	#pass
