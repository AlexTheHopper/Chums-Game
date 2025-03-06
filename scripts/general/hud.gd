extends CanvasLayer

@onready var health_bar = $Control/HealthPanel/PlayerHealthBar
@onready var chum_count = $Control/ChumCountPanel/Value
@onready var anim_player = $Control/AnimationPlayer

func _ready() -> void:
	PlayerStats.hud_health_change.connect(change_health)
	change_health()
	PlayerStats.hud_max_health_change.connect(change_max_health)
	change_max_health()
	PlayerStats.hud_bracelets_change.connect(change_bracelets)
	change_bracelets()
	
	PlayerStats.player_chums_changed.connect(change_chum_count)
	chum_count.text = "0 / " + str(PlayerStats.player_max_chums)
	
	PlayerStats.insufficient_bracelets.connect(indicate_bracelets)
	PlayerStats.too_many_chums.connect(indicate_chum_count)

func change_health():
	health_bar.set_health(PlayerStats.player_health)
	
func change_max_health():
	health_bar.set_max_health(PlayerStats.player_max_health)
	
func change_chum_count():
	chum_count.text = str(len(get_tree().get_nodes_in_group("Chums_Friend"))) + " / " + str(PlayerStats.player_max_chums)

func change_bracelets():
	$Control/BraceletsPanel/Value.text = str(PlayerStats.bracelets)
	
func indicate_bracelets():
	anim_player.play("insufficient_bracelets")
func indicate_chum_count():
	anim_player.play("too_many_chums")
