extends Node

@onready var player: CharacterBody3D
@onready var health_node

@onready var player_health: float
@onready var player_max_health: float
@onready var bracelets := 0
@onready var player_max_chums := 5 if not Global.dev_mode else 10
@onready var collected_lanterns := {0: false, 1: false, 2: false, 3: false, 4: false}

signal hud_health_change
signal hud_max_health_change
signal hud_bracelets_change

signal player_chums_changed
signal player_chums_increased
signal player_chums_decreased

signal player_max_chums_increase

signal insufficient_bracelets
signal too_many_chums

func initialize() -> void:
	player = get_tree().get_first_node_in_group("Player")
	health_node = player.get_node("Health")

	health_node.health_changed.connect(_on_player_health_changed)
	player_health = health_node.health

	health_node.max_health_changed.connect(_on_player_max_health_changed)
	player_max_health = health_node.max_health
	
	#To trigget sets:
	bracelets = 0
	player_max_chums = player_max_chums
	
func _on_player_health_changed(_difference):
	player_health = health_node.health
	hud_health_change.emit()
	
func _on_player_max_health_changed(_differnce):
	player_max_health = health_node.max_health
	hud_max_health_change.emit()
	
func bracelets_added(value):
	bracelets += value
	hud_bracelets_change.emit()
	
func friend_chums_changed(change, chum):
	player_chums_changed.emit()
	if change > 0:
		player_chums_increased.emit(chum)
	else:
		player_chums_decreased.emit(chum)

func add_max_chums(n):
	player_max_chums_increase.emit(n)
	player_max_chums += n
	
func emit_insufficient_bracelets():
	insufficient_bracelets.emit()
	
func emit_too_many_chums():
	too_many_chums.emit()
	
func is_chum_list_full():
	return len(get_tree().get_nodes_in_group("Chums_Friend")) >= player_max_chums
