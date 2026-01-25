extends Node3D
class_name Quality_Popup

@onready var camera := get_viewport().get_camera_3d()
@onready var chum := get_parent()
@onready var mesh_scene : Node
@onready var mesh_node := $Container/MeshNode
var base_scale := Vector3.ONE
var fading_out := false

@export var control: Control
@export var disp_name: Label

@export var disp_name_back: Label
@export var desc_back: Label
@export var book_display: Control

var rotations := 1.0

func _ready() -> void:
	#Set visuals:
	var mesh_num = 1
	if Global.current_world_num == 0:
		mesh_num = Global.room_location[0]
	elif Global.current_world_num:
		mesh_num = Global.current_world_num
	if not mesh_num:
		mesh_num = 1
		
	mesh_scene = load("res://assets/world/quality_popup_%s.tscn" % [mesh_num]).instantiate()
	mesh_node.add_child(mesh_scene)
	
	#Set all values:
	#Front
	disp_name.text = chum.chum_name
	create_bracelet_icons(chum.bracelet_cost)
	var pos = Vector2(150, 150)
	var middle_x = 350.0
	var icon_len = 50.0
	for type in ["health", "move_speed", "attack_damage", "attack_speed"]:
		var icons = get_quality_images(chum.quality[type])
		if not chum.get("has_%s" % type):
			pos.x = middle_x - (icon_len / 2.0)
			create_icon(-10, pos)
		elif len(icons.keys()) == 0:
			pos.x = middle_x - (icon_len / 2.0)
			create_icon(0, pos)
		else:
			var icon_num = abs(icons.values().reduce(func(a, b): return a + b))
			var icon_i := 1
			for lvl in icons.keys():
				for num in range(abs(icons[lvl])):
					pos.x = get_star_position(middle_x, icon_i, icon_num, 6)
					create_icon(lvl if icons[lvl] > 0 else -lvl, pos)
					icon_i += 1
		pos.y += 80
		
	#Back
	disp_name_back.text = disp_name.text
	if chum.chum_id in PlayerStats.player_unique_chums_befriended:
		desc_back.text = chum.chum_desc
		desc_back.visible = true
		book_display.visible = false
	else:
		desc_back.visible = false
		book_display.visible = true
	
	scale = Vector3(0.1, 0.1, 0.1)
	chum.has_quality_popup = true
	ChumsManager.quality_popup_active = true

func _process(_delta: float) -> void:
	
	#Keep facing the camera, rotates on input "rotate"
	if Input.is_action_just_pressed("rotate"):
		rotations += 1.0
	$Container.rotation.y = lerp($Container.rotation.y, rotations * PI - PI, 0.075)
	look_at(camera.global_position)


	if camera and not fading_out:
		var distance = global_position.distance_to(camera.global_position)
		var scale_factor = distance / 12
		scale = lerp(scale, base_scale * scale_factor, 0.05)
		
		#If player cycles through quality popups:
		if Input.is_action_just_pressed("cycle") and len(ChumsManager.close_chums) > 1:
			remove()
			#Cycle through close chums:
			var closest_chum = ChumsManager.close_chums[0]
			ChumsManager.close_chums.erase(closest_chum)
			ChumsManager.close_chums.append(closest_chum)
			
			#Reinstantiate quality popup for close chum(s)
			for close_chum in ChumsManager.close_chums:
				close_chum.interaction_area._on_body_entered(get_tree().get_first_node_in_group("Player"))
	
	else:
		scale = lerp(scale, Vector3(0.05, 0.05, 0.05), 0.1)
		
		if scale.x < 0.1:
			queue_free()

func create_icon(value: int, pos: Vector2) -> void:
	var tex_rect := TextureRect.new()
	tex_rect.position = pos
	tex_rect.texture = load("res://assets/world/quality_icons/quality_%s.png" % str(value))
	tex_rect.size = Vector2(50.0, 50.0)
	tex_rect.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	control.add_child(tex_rect)

func create_bracelet_icons(count: int) -> void:
	var pos := Vector2(256.0 - (25.0 * count / 2.0), 100.0)
	for b in count:
		var tex_rect := TextureRect.new()
		tex_rect.position = pos
		tex_rect.texture = load("res://assets/world/quality_icons/staticon_bracelet.png")
		tex_rect.size = Vector2(25.0, 25.0)
		tex_rect.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		control.add_child(tex_rect)
		pos.x += 25.0

func get_star_position(center: float, star_num: int, star_count: int, max_star_num: int, icon_len:=50.0, margin_l:=175.0, margin_r:=475.0) -> float:
	if star_count <= max_star_num:
		return center - (icon_len * star_count / 2.0) + (icon_len * star_num) - icon_len
	else:
		return lerp(margin_l, margin_r, star_num / (1.0 + star_count))

func get_quality_images(quality: int) -> Dictionary[int, int]:
	if quality == 0:
		return {}
	#Quality should never really be below -2 anyway.
	elif quality < 0:
		return {1: quality}

	quality = abs(quality)
	var lvl_5 = floor(quality / 81.0)
	quality -= lvl_5 * 81.0
	var lvl_4 = floor(quality / 27.0)
	quality -= lvl_4 * 27.0
	var lvl_3 = floor(quality / 9.0)
	quality -= lvl_3 * 9.0
	var lvl_2 = floor(quality / 3.0)
	quality -= lvl_2 * 3.0
	var lvl_1 = floor(quality / 1.0)
	return {5: int(lvl_5),
			4: int(lvl_4),
			3: int(lvl_3),
			2: int(lvl_2),
			1: int(lvl_1),
			}

func remove():
	ChumsManager.quality_popup_active = false
	chum.has_quality_popup = false
	fading_out = true
