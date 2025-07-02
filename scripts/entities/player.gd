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
var charging := 0.0
var attacking_mult := 1.0

@export var jump_height: float = 2
@export var jump_peak_time: float = 0.3
@export var jump_fall_time: float = 0.25

@onready var jump_velocity: float = (2.0 * jump_height) / jump_peak_time
@onready var jump_gravity: float = (-2.0 * jump_height) / (jump_peak_time ** 2)
@onready var fall_gravity: float = (-2.0 * jump_height) / (jump_fall_time ** 2)

@export var hitbox: Hitbox
@export var hurtbox: Hurtbox
@export var base_damage := 10
@export var max_extra_damage := 20
@onready var particle_zone := $Particles
@onready var health_node := $Health
@onready var anim_player := $AnimationPlayer
@onready var lantern := $Armature/Skeleton3D/BoneAttachment3D/Lantern

@onready var hurt_particles := load("res://particles/damage_friendly.tscn")
@onready var heal_particles := load("res://particles/heal_friendly.tscn")
@onready var hurt_particles_num := load("res://particles/damage_num_friendly.tscn")

var changes_agro_on_damaged := true
var draws_agro_on_attack := true
var maintains_agro := 0.0
var targeted_by := []


var xform: Transform3D
var chum_name := "Player"

func _ready() -> void:
	Global.game_begun = true
	health_node.immune = false
	health_node.set_max_health(100)
	health_node.set_health(100)
	anim_player.play("RESET")
	if Global.dev_mode:
		base_damage = 50
		max_extra_damage = 100

		hitbox.damage = base_damage	

func _physics_process(delta: float) -> void:
	if not Global.is_alive:
		return
	# Get the input direction and handle the movement/deceleration.
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	#Gets transformed input direction
	var direction = ($Camera_Controller.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	#Animations:
	#Attack:
	if Input.is_action_just_pressed("attack") and not is_attacking and not is_carrying and Global.is_alive:
		is_attacking = true
		charging += delta
		attacking_mult = 0.1
		anim_player.play("Swing")
		anim_player.speed_scale = 0.12
		anim_player.animation_finished.connect(_on_attack_finished, CONNECT_ONE_SHOT)
	elif not is_attacking and Global.is_alive:
		if Input.is_action_pressed("jump") and is_on_floor():
			anim_player.play("Jump_Carry" if is_carrying else "Jump_noCarry")
		elif input_dir != Vector2.ZERO and is_on_floor():
			anim_player.play("Run_Carry" if is_carrying else "Run_noCarry")
		elif input_dir == Vector2.ZERO and is_on_floor():
			anim_player.play("Idle_Carry" if is_carrying else "Idle_noCarry")
		attacking_mult = lerp(attacking_mult, 1.0, 0.05)
		
	#Increment charging and manage lantern size:
	if charging > 0:
		charging += delta
		if charging > 0.5:
			lantern.scale = lerp(lantern.scale, Vector3(1.5, 1.5, 1.5), 0.02)
	#Varying damage based on charge:
	if (Input.is_action_just_released("attack") and charging > 0.0) or charging > 2.0:
		var damage_modifier = Functions.map_range(charging, Vector2(0.5, 2.0), Vector2(0.0, 1.0))
		var attack_damage = base_damage + int(damage_modifier * max_extra_damage)
		hitbox.damage = attack_damage
		anim_player.speed_scale = 1.0
		charging = 0.0
	
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
		$Armature.rotation.y = lerp_angle($Armature.rotation.y, player_goal_horz, 0.35 * attacking_mult)
		$Armature.rotation.x = lerp_angle($Armature.rotation.x, 0.15, 0.05)
	else:
		$Armature.rotation.x = lerp_angle($Armature.rotation.x, 0.0, 0.1)

	#Move character:
	if direction:
		velocity.x = direction.x * SPEED * attacking_mult * (0.1 if is_launched else 1.0)
		velocity.z = direction.z * SPEED * attacking_mult * (0.1 if is_launched else 1.0)

	#Slow down after letting go of controls
	elif not is_launched:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
	#Match camera controller position to self
	$Camera_Controller.position = lerp($Camera_Controller.position, position, 0.1)
	
			
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("print_fps") and Global.dev_mode:
		get_tree().call_group("Chums_Enemy", "put_to_sleep_temp", 5.0)
		print("FPS: " + str(Engine.get_frames_per_second()))
		print('player health: ' + str(health_node.health))
		print('player max health: ' + str(health_node.max_health))
		print('player damage: ' + str(base_damage))
		print('player extra damage: ' + str(max_extra_damage))
		print('player pos: ' + str(global_position))

		print("friends:")
		for chum in get_tree().get_nodes_in_group("Chums_Friend"):
			print(chum.chum_name)
			print(chum.hitbox.damage)
			print(chum.quality)
			print(chum.health_node.health)
			if chum.target:
				print("Target: " + str(chum.target))
		print("enemies:")
		for chum in get_tree().get_nodes_in_group("Chums_Enemy"):
			print(chum.chum_name)
			print(chum.hitbox.damage)
			print(chum.quality)
			print(chum.health_node.health)
			if chum.target:
				print("Target: " + str(chum.target))
		print("neutral:")
		for chum in get_tree().get_nodes_in_group("Chums_Neutral"):
			print(chum.chum_name)
			print(chum.hitbox.damage)
			print(chum.quality)
			print(chum.health_node.health)
			if chum.target:
				print("Target: " + str(chum.target))
			
func _on_attack_finished(_anim_name):
	is_attacking = false
	charging = 0.0
	hitbox.damage = base_damage
	lantern.scale = Vector3(1.0, 1.0, 1.0)

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
		damaged(-difference)
	elif difference > 0.0:
		healed(difference)

func damaged(amount):
	$Hurtbox/AnimationPlayer.play("Hurt")
	particle_zone.add_child(hurt_particles.instantiate())
	
	var hurt_num_inst = hurt_particles_num.instantiate()
	hurt_num_inst.get_child(0).mesh.text = "-" + str(amount)
	particle_zone.add_child(hurt_num_inst)

func healed(amount):
	particle_zone.add_child(heal_particles.instantiate())
	
	var heal_num_inst = hurt_particles_num.instantiate()
	heal_num_inst.get_child(0).mesh.text = "+" + str(amount)
	particle_zone.add_child(heal_num_inst)

func _on_health_health_depleted() -> void:
	#Stop all chums from battling
	Global.is_alive = false
	anim_player.speed_scale = 1.0
	for group in ["Chums_Enemy", "Chums_Neutral", "Chums_Friend"]:
		for chum in get_tree().get_nodes_in_group(group):
			chum.set_state("Idle")
	anim_player.play("Death")
	
func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "Death":
		call_deferred("kill_player")

func has_damage() -> bool:
	return health_node.get_health() < health_node.get_max_health()
	
func get_agro_change_target():
	return self

func increase_stats(amount: int) -> void:
	base_damage += amount
	max_extra_damage += int(amount / 2.0)
	
	health_node.max_health += int(amount / 2.0)

func kill_player():
	Global.return_to_menu(true)
