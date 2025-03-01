extends Node

@onready var player := get_tree().get_first_node_in_group("Player")
@onready var health_node := player.get_node("Health")

@onready var player_health: float
@onready var player_max_health: float
@onready var bracelets := 0

signal hud_health_change
signal hud_max_health_change
signal hud_bracelets_change

func _ready() -> void:
	health_node.health_changed.connect(_on_player_health_changed)
	player_health = health_node.health
	
	health_node.max_health_changed.connect(_on_player_max_health_changed)
	player_max_health = health_node.max_health
	
func _on_player_health_changed(_difference):
	player_health = health_node.health
	hud_health_change.emit()
	
func _on_player_max_health_changed(_differnce):
	player_max_health = health_node.max_health
	hud_max_health_change.emit()
	
func bracelets_added(value):
	bracelets += value
	hud_bracelets_change.emit()
