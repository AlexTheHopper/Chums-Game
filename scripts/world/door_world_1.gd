extends CharacterBody3D
@export var animation_player: AnimationPlayer


func lower():
	animation_player.play("lower")
	
func raise():
	animation_player.play("raise")
