extends Node

@onready var player: CharacterBody3D
@onready var health_node

@onready var player_health: float
@onready var player_max_health: float
@onready var bracelets := 0
@onready var player_max_chums := 5 if not Global.dev_mode else 10
@onready var collected_lanterns := {0: false, 1: false, 2: false, 3: false, 4: false}
@onready var player_chums_befriended := 0
@onready var player_unique_chums_befriended := []
@onready var player_bracelets_collected := 0
@onready var player_bracelets_spent := 0

var AppID := "480"
enum ACHIEVEMENTS {
	ON_RECRUIT_CHUM,
	ON_RECRUIT_PRISONER,
	ON_STATUE_ENTER,
	ON_CRATE_BREAK,
	ON_PRISONERS_APPLIED,
	ON_ALL_LANTERNS,
	
	ON_FOUNTAINPOOL_USE,
	ON_UPGRADEPOOL_USE,
	ON_VOIDPOOL_USE,
	ON_SWAPPOOL_USE,
	ON_SACRIFICEPOOL_USE,
}

signal hud_health_change
signal hud_max_health_change
signal hud_bracelets_change

signal player_chums_changed
signal player_chums_increased
signal player_chums_decreased

signal player_max_chums_increase

signal insufficient_bracelets
signal too_many_chums

func _init() -> void:
	OS.set_environment("SteamAppID", AppID)
	OS.set_environment("SteamGameID", AppID)

func _ready() -> void:
	Steam.steamInit()
	var isSteamRunning: bool = Steam.isSteamRunning()
	if not isSteamRunning:
		Global.print_dev("STEAM NOT RUNNING")
		return
	
	Global.print_dev("Steam Running")

func initialise() -> void:
	player_max_chums = 5 if not Global.dev_mode else 10
	collected_lanterns = {0: false, 1: false, 2: false, 3: false, 4: false}
	player = get_tree().get_first_node_in_group("Player")
	health_node = player.get_node("Health")

	health_node.health_changed.connect(_on_player_health_changed)
	player_health = health_node.health

	health_node.max_health_changed.connect(_on_player_max_health_changed)
	player_max_health = health_node.max_health
	
	player_chums_befriended = 0
	player_unique_chums_befriended = []
	player_bracelets_collected = 0
	player_bracelets_spent = 0
	
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
	bracelets = clamp(bracelets + value, 0, 999)
	hud_bracelets_change.emit()
	
	if value > 0:
		player_bracelets_collected += value
	else:
		player_bracelets_spent -= value
	
func friend_chums_changed(change, chum):
	player_chums_changed.emit()
	if change > 0:
		player_chums_increased.emit(chum)
	else:
		player_chums_decreased.emit(chum)

func add_max_chums(n):
	player_max_chums_increase.emit(n)
	player_max_chums += n
	
	if false not in collected_lanterns.values():
		PlayerStats.attempt_achievement_unlock(PlayerStats.ACHIEVEMENTS.ON_ALL_LANTERNS)
	
func emit_insufficient_bracelets():
	insufficient_bracelets.emit()
	
func emit_too_many_chums():
	too_many_chums.emit()
	
func is_chum_list_full():
	return len(get_tree().get_nodes_in_group("Chums_Friend")) >= player_max_chums

#Achievement Manager Function, to unlock achievement ACH call:
#PlayerStats.attempt_achievement_unlock(PlayerStats.ACHIEVEMENTS.ACH)
func attempt_achievement_unlock(ACH: ACHIEVEMENTS) -> void:
	var ach = ACHIEVEMENTS.keys()[ACH]
	Global.print_dev("Attempting Unlock of Achievement: %s" % ach)
	var status = Steam.getAchievement(ach)
	if not status.has("achieved"):
		Global.print_dev("Error Unlocking Achievement: %s" % ach)
		return
	if status["achieved"]:
		Global.print_dev("Achievement Already Unlocked: %s" % ach)
		return
	Global.print_dev("New Achievement Unlocked: %s" % ach)
	Steam.setAchievement(ach)
