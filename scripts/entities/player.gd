extends CharacterBody3D
class_name Player

const SPEED := 7.5
const ACCEL := 0.3
const SLOW_ACCEL := ACCEL * 3.0
const MAX_SPEED := 10.0

var jumping_time := 30.0
const JUMPING_VELOCITY := 0.2
const MAX_JUMPING_TIME := 30.0
const MAX_COYOTE := 10.0
var in_jump := false
var coyote_time := MAX_COYOTE

var player_goal_horz := 0.0
var camera_goal_horz := 0.0
var camera_goal_vert := 0.0

var can_align := true
var is_carrying := false
var is_attacking := false
var is_launched := false
var attacking_mult := 1.0

@export var jump_height: float = 2
@export var jump_peak_time: float = 0.3
@export var jump_fall_time: float = 0.25

@onready var jump_velocity: float = (2.0 * jump_height) / jump_peak_time
@onready var jump_gravity: float = (-2.0 * jump_height) / (jump_peak_time ** 2)
@onready var fall_gravity: float = (-2.0 * jump_height) / (jump_fall_time ** 2)

@export var hitbox: Hitbox
@export var hurtbox: Hurtbox
@onready var particle_zone := $Particles
@onready var health_node := $Health
@onready var anim_player := $AnimationPlayer

var changes_agro_on_damaged = true
var draws_agro_on_attack = true
var maintains_agro = false
var targeted_by := []


var xform: Transform3D

func _ready() -> void:
	Global.game_begun = true
	$Health.immune = false
	$Health.set_max_health(10.0)
	$Health.set_health(10.0)
	
	hitbox.attack_info = {"speed": [1.3, 1.4, 1.5, 1.6, 1.7, 1.8].pick_random(),
							"damage": [0.8, 1.0, 1.2].pick_random(),
							"distance": 1.5,
							"single_target": true}
	

func _physics_process(delta: float) -> void:
	# Get the input direction and handle the movement/deceleration.
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	#Gets transformed input direction
	var direction = ($Camera_Controller.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	#Animations:
	#Attack:
	if Input.is_action_just_pressed("attack") and not is_attacking and not is_carrying:
		anim_player.play("Swing")
		is_attacking = true
		attacking_mult = 0.1
		anim_player.animation_finished.connect(_on_attack_finished, CONNECT_ONE_SHOT)
	elif not is_attacking:
		if Input.is_action_pressed("jump") and is_on_floor():
			anim_player.play("Jump_Carry" if is_carrying else "Jump_noCarry")
		elif input_dir != Vector2.ZERO and is_on_floor():
			anim_player.play("Run_Carry" if is_carrying else "Run_noCarry")
		elif input_dir == Vector2.ZERO and is_on_floor():
			anim_player.play("Idle_Carry" if is_carrying else "Idle_noCarry")
			
		attacking_mult = lerp(attacking_mult, 1.0, 0.05)
	
	#Rotating camera:
	if Input.is_action_just_pressed("cam_left"):
		camera_goal_horz += deg_to_rad(45)
	elif Input.is_action_just_pressed("cam_right"):
		camera_goal_horz -= deg_to_rad(45)
	$Camera_Controller.rotation.y = lerp($Camera_Controller.rotation.y, camera_goal_horz, 0.05)
	
	if Input.is_action_just_pressed("cam_down"):
		camera_goal_vert = clamp(camera_goal_vert - 0.5, 0, 1)
	elif Input.is_action_just_pressed("cam_up"):
		camera_goal_vert = clamp(camera_goal_vert + 0.5, 0, 1)
	$Camera_Controller/Camera_Path/PathFollow3D.progress_ratio = lerp($Camera_Controller/Camera_Path/PathFollow3D.progress_ratio, camera_goal_vert, 0.03)


	# Handle jump.
	if Input.is_action_pressed("jump"):
		jump()
	elif Input.is_action_just_released("jump"):
		jumping_time = 0
		
	# Add the gravity.
	if is_on_floor():
		jumping_time = MAX_JUMPING_TIME
		coyote_time = MAX_COYOTE
		in_jump = false
		is_launched = false
		#align_with_floor($RayCast3D.get_collision_normal())
	else:
		velocity.y += get_gravity_dir() * delta
		coyote_time = max(0, coyote_time - 1)
		#align_with_floor(Vector3.UP)
		
	if Input.is_anything_pressed():
		can_align = true
	elif is_on_floor():
		can_align = false


	#Rotate character:
	if input_dir:
		player_goal_horz = $Camera_Controller.rotation.y - input_dir.angle() - (PI / 2)
		player_goal_horz = fmod(player_goal_horz + PI, 2 * PI)
		$Armature.rotation.y = lerp_angle($Armature.rotation.y, player_goal_horz, 0.35)

	#Move character:
	if direction and not is_launched:
		velocity.x = direction.x * SPEED * attacking_mult
		velocity.z = direction.z * SPEED * attacking_mult

	#Slow down after letting go of controls
	elif not is_launched:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
	#Match camera controller position to self
	$Camera_Controller.position = lerp($Camera_Controller.position, position, 0.1)
	
			
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("print_fps"):
		print("FPS: " + str(Engine.get_frames_per_second()))
		print('player health: ' + str($Health.health))
		print('player pos: ' + str(global_position))
		#for room in Global.world_map:
			#print(room)
			#print(Global.world_map[room])
		#print("Enemies' positions:")
		#for chum in get_tree().get_nodes_in_group("Chums_Enemy"):
			#print(chum.global_position)
		#print("Neutrals' positions:")
		#for chum in get_tree().get_nodes_in_group("Chums_Neutral"):
			#print(chum.global_position)
		print("friends:")
		for chum in get_tree().get_nodes_in_group("Chums_Friend"):
			print(chum.attack)
			print(chum.quality)
			print(chum.health_node.health)
		print("enemies:")
		for chum in get_tree().get_nodes_in_group("Chums_Enemy"):
			print(chum.attack)
			print(chum.quality)
			print(chum.health_node.health)
		print("neutral:")
		for chum in get_tree().get_nodes_in_group("Chums_Neutral"):
			print(chum.attack)
			print(chum.quality)
			print(chum.health_node.health)
			
func _on_attack_finished(_anim_name):
	is_attacking = false

func jump():
	if (is_on_floor() or coyote_time > 0) and not in_jump and not is_attacking:
		velocity.y = jump_velocity
		in_jump = true

	if jumping_time:
		velocity.y += JUMPING_VELOCITY
		jumping_time = max(0, jumping_time - 1)
	
func get_gravity_dir():
	return fall_gravity if velocity.y < 0.0 else jump_gravity

func align_with_floor(normal):
	if can_align:
		xform = global_transform
		xform.basis.y = normal
		xform.basis.x = -xform.basis.z.cross(normal)
		xform.basis = xform.basis.orthonormalized()
			
		global_transform = global_transform.interpolate_with(xform, 0.3)
		rotation.y = 0
		
func _on_health_changed(difference):
	if difference < 0.0:
		$Hurtbox/AnimationPlayer.play("Hurt")

func _on_health_health_depleted() -> void:
	call_deferred("kill_player")

func kill_player():
	get_tree().reload_current_scene()
	Global.reset()
	
