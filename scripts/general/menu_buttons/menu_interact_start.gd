extends MenuInteract

var save_nums := []
var existing_save_nums := []
var save_index = 0

@onready var text_label: Label = $Value

signal start_game
signal save_changed

func _ready() -> void:
	await owner.ready #Needs the list of saves passed to it after main menu has loaded them
	change_text()

func interact() -> void:
	start_game.emit(save_nums[save_index])

func left() -> void:
	if save_nums.size() <= 1:
		return
	save_index -= 1
	if save_index < 0:
		save_index = save_nums.size() - 1
	save_changed.emit(save_nums[save_index], true)
	change_text()

func right() -> void:
	if save_nums.size() <= 1:
		return
	save_index += 1
	if save_index > save_nums.size() - 1:
		save_index = 0
	save_changed.emit(save_nums[save_index], true)
	change_text()

func change_text() -> void:
	if save_nums[save_index] == null:
		text_label.text = tr("NEW_REALITY")
	elif save_nums[save_index] not in existing_save_nums:
		text_label.text = tr("RESURRECT_REALITY") + ": %s" % save_nums[save_index]
	else:
		text_label.text = tr("REALITY") + ": %s" % save_nums[save_index]
