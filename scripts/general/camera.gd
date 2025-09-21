extends Camera3D

@export var shake_power := 0.15
@export var shake_fade := 5.0

var current_shake := 0.0

func trigger_shake(strength = 1.0) -> void:
	current_shake = shake_power * strength

func _process(delta: float) -> void:
	if current_shake > 0.0:
		current_shake = lerp(current_shake, 0.0, shake_fade * delta)
	
		h_offset = randf_range(-current_shake, current_shake)
		v_offset = randf_range(-current_shake, current_shake)
