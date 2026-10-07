extends Node2D
## Malware-flagging puzzle: the player clicks the files they think are malware.

## Emitted when every malware file is flagged and the player dismisses the score.
signal finished
## Emitted when the player leaves before completing the puzzle.
signal closed

const CORRECT_REWARD := 100
const INCORRECT_PENALTY := 50

@onready var file_buttons: Array[Node] = $FileButtons.get_children()
@onready var popup: PopupPanel = $Feedback
@onready var popup_label: Label = $Feedback/Label
@onready var popup_continue: Button = $Feedback/ContinueButton
@onready var return_button: Button = $ReturnButton
@onready var camera: Camera2D = $flagpuzzlecamera

var filenames: Array[String] = [
	"Resume.docx",
	"Update.zip",
	"trojan.exe",
	"meeting_notes.pdf",
	"cat_video.src",
]

var malware_files: Array[String] = ["trojan.exe", "cat_video.src", "Update.zip"]

var correct_flags := 0
var incorrect_flags := 0
var completed := false


func _ready() -> void:
	for i in file_buttons.size():
		var button: BaseButton = file_buttons[i]
		button.get_node("FileLabel").text = filenames[i]
		button.pressed.connect(_on_file_pressed.bind(button, filenames[i]))

	popup_continue.pressed.connect(_on_feedback_continue_pressed)
	return_button.pressed.connect(_on_return_pressed)
	return_button.tooltip_text = "Close this window and return to office."


## Resets the puzzle, shows the briefing and takes over the camera.
func start() -> void:
	correct_flags = 0
	incorrect_flags = 0
	completed = false
	for button in file_buttons:
		button.get_node("Flag").visible = false
		button.set_meta("flagged", false)
	popup.hide()
	_set_briefing_visible(true)
	camera.make_current()


func _set_briefing_visible(shown: bool) -> void:
	$intro2.visible = shown
	$intro3.visible = shown
	$Continue2.visible = shown
	$Label.visible = shown


func _on_file_pressed(button: BaseButton, filename: String) -> void:
	if completed or button.get_meta("flagged", false):
		return
	button.set_meta("flagged", true)
	button.get_node("Flag").visible = true

	if malware_files.has(filename):
		correct_flags += 1
		Global.score += CORRECT_REWARD
		popup_label.text = "Correct! '%s' is malware.\n(Click to continue)" % filename
		if correct_flags == malware_files.size():
			completed = true
			popup_label.text += "\n\nAll malware flagged!\n" + _score_summary()
	else:
		incorrect_flags += 1
		Global.score -= INCORRECT_PENALTY
		popup_label.text = "Incorrect. '%s' is safe.\n(Click to continue)" % filename

	popup.popup_centered()


func _score_summary() -> String:
	var attempts := correct_flags + incorrect_flags
	var percent := int(correct_flags * 100.0 / attempts)
	return "Accuracy: %d%%  (Correct: %d, Incorrect: %d)" % [percent, correct_flags, incorrect_flags]


func _on_feedback_continue_pressed() -> void:
	popup.hide()
	if completed:
		finished.emit()


func _on_return_pressed() -> void:
	popup.hide()
	if completed:
		finished.emit()
	else:
		closed.emit()


func _on_continue_2_pressed() -> void:
	_set_briefing_visible(false)
