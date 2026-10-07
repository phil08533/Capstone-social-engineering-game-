extends Node2D
## Drives the story timeline of the office level.
##
## The game is a fixed sequence of beats. Each beat waits for exactly one thing
## (a dialogue ending, the player interacting with the alert, a puzzle
## finishing), then moves on to the next. Nothing is polled per frame.
##
##   INTRO -> EMAIL_1 -> CHAT_2 -> EMAIL_2 -> CHAT_3 -> USB -> FINISHED
##
## The dialogue text lives in timeline.dtl and is selected by the Dialogic
## variable `chatstep` (0 = intro, 1 = after first email, 2 = after second).

enum Stage { INTRO, EMAIL_1, CHAT_2, EMAIL_2, CHAT_3, USB, FINISHED }

const MAIN_MENU := "res://Godot_Game_Files/main_menu.tscn"
const TIMELINE := "timeline"

## Where the "!" alert floats for each stage that waits on the player.
const ALERT_SPOTS := {
	Stage.EMAIL_1: Vector2(109, 371),
	Stage.EMAIL_2: Vector2(357, 371),
	Stage.USB: Vector2(235, 371),
}

var stage: Stage = Stage.INTRO

@onready var alert: Area2D = $Event_Tree/Puzzles/EmailAlert
@onready var email_puzzle: Node2D = $PhisingEmail
@onready var usb_puzzle: Node2D = $dowload
@onready var player_body: CharacterBody2D = $Player/CharacterBody2D
@onready var player_camera: Camera2D = $Player/CharacterBody2D/Playercamera2d


func _ready() -> void:
	Global.reset()
	player_camera.make_current()
	alert.set_active(false)
	alert.activated.connect(_on_alert_activated)
	Dialogic.timeline_ended.connect(_on_timeline_ended)
	email_puzzle.finished.connect(_on_puzzle_finished)
	usb_puzzle.finished.connect(_on_puzzle_finished)
	usb_puzzle.closed.connect(_on_puzzle_closed)
	_play_chat(0)


func _exit_tree() -> void:
	# Dialogic is an autoload and outlives this scene.
	if Dialogic.timeline_ended.is_connected(_on_timeline_ended):
		Dialogic.timeline_ended.disconnect(_on_timeline_ended)


func _play_chat(step: int) -> void:
	alert.set_active(false)
	player_body.set_physics_process(false)
	Dialogic.VAR.chatstep = step
	Dialogic.start(TIMELINE)


func _on_timeline_ended() -> void:
	player_body.set_physics_process(true)
	match stage:
		Stage.INTRO:
			_wait_for_player(Stage.EMAIL_1)
		Stage.CHAT_2:
			_wait_for_player(Stage.EMAIL_2)
		Stage.CHAT_3:
			_wait_for_player(Stage.USB)


func _wait_for_player(next_stage: Stage) -> void:
	stage = next_stage
	alert.position = ALERT_SPOTS[stage]
	alert.set_active(true)


func _on_alert_activated() -> void:
	alert.set_active(false)
	player_body.set_physics_process(false)
	match stage:
		Stage.EMAIL_1, Stage.EMAIL_2:
			email_puzzle.start()
		Stage.USB:
			usb_puzzle.start()


func _on_puzzle_finished() -> void:
	player_camera.make_current()
	match stage:
		Stage.EMAIL_1:
			stage = Stage.CHAT_2
			_play_chat(1)
		Stage.EMAIL_2:
			stage = Stage.CHAT_3
			_play_chat(2)
		Stage.USB:
			stage = Stage.FINISHED
			player_body.set_physics_process(true)
			_show_ending()


## The player backed out of a puzzle without completing it: the alert stays.
func _on_puzzle_closed() -> void:
	player_camera.make_current()
	player_body.set_physics_process(true)
	alert.set_active(true)


func _show_ending() -> void:
	var layer := CanvasLayer.new()
	layer.layer = 10
	add_child(layer)

	var panel := PanelContainer.new()
	panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	layer.add_child(panel)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 12)
	panel.add_child(box)

	var label := Label.new()
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.text = "Shift complete!\nBoss salary earned: $%d" % Global.score
	box.add_child(label)

	var button := Button.new()
	button.text = "Back to main menu"
	button.pressed.connect(func() -> void: get_tree().change_scene_to_file(MAIN_MENU))
	box.add_child(button)
