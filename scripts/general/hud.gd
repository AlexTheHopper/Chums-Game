extends CanvasLayer

@onready var health_bar = $Control/HealthPanel/PlayerHealthBar

func _ready() -> void:
	PlayerStats.hud_health_change.connect(change_health)
	change_health()
	PlayerStats.hud_max_health_change.connect(change_max_health)
	change_max_health()
	PlayerStats.hud_bracelets_change.connect(change_bracelets)
	change_bracelets()

func change_health():
	health_bar.set_health(PlayerStats.player_health)
	
func change_max_health():
	health_bar.set_max_health(PlayerStats.player_max_health)

func change_bracelets():
	$Control/BraceletsPanel/Value.text = str(PlayerStats.bracelets)
