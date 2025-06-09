extends Node3D

@onready var camera: Camera3D = $Camera3D
@onready var camera_a: float = 0

var starting_game = false

func _process(delta: float) -> void:
	camera_a += delta / 25
	
	if Input.is_action_just_pressed("attack") and not starting_game:
		starting_game = true
		TransitionScreen.transition(3)
		await TransitionScreen.on_transition_finished
		Global.start_game(1)
		queue_free()
	
func _physics_process(_delta: float) -> void:
	camera.global_position = Vector3(15 * sin(camera_a), 10, 15 * cos(camera_a))
	camera.rotation.y = camera_a - (PI / 4)
