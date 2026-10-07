extends Node2D

@onready var file_buttons = $FileButtons.get_children()
@onready var popup = $Feedback
@onready var popup_label = $Feedback/Label
@onready var start_button = $Feedback/ContinueButton
@onready var return_button = $ReturnButton

var filenames = [
	"Resume.docx",
	"Update.zip",
	"trojan.exe",
	"meeting_notes.pdf",
	"cat_video.src",
]

var malware_files = ["trojan.exe", "cat_video.src", "Update.zip"]  # Set your 3 malware files

var correct_flags = 0
var incorrect_flags = 0

func _ready():
	for i in range(file_buttons.size()):
		var button = file_buttons[i]
		button.get_node("FileLabel").text = filenames[i]
		button.set_meta("index", i)
		button.set_meta("flagged", false)
		button.get_node("Flag").visible = false
		button.connect("pressed", Callable(self, "_on_file_pressed").bind(button))

	start_button.connect("pressed", Callable(self, "_on_start_button_pressed"))
	return_button.connect("pressed", Callable(self, "_on_return_pressed"))
	return_button.tooltip_text = "Close this window and return to office."

func _on_start_button_pressed():
	popup.hide()

func _on_file_pressed(button):
	var index = button.get_meta("index")
	var already_flagged = button.get_meta("flagged")

	if already_flagged:
		return

	var filename = filenames[index]
	var is_malware = malware_files.has(filename)

	button.set_meta("flagged", true)
	button.get_node("Flag").visible = true

	if is_malware:
		correct_flags += 1
		popup_label.text = "Correct! '%s' is malware. \n(Click to continue)" % filename

		if correct_flags == malware_files.size():
			popup_label.text += "\n\nAll malware flagged!"
			popup.popup_centered()
			await get_tree().create_timer(3.0).timeout
			show_score_popup()
			return
	else:
		incorrect_flags += 1
		popup_label.text = "Incorrect. '%s' is safe. \n(Click to continue)" % filename

	popup.popup_centered()


func _on_return_pressed():
	$"../Player/CharacterBody2D/Playercamera2d".make_current()

func show_score_popup():
	var attempts = correct_flags + incorrect_flags
	var total_malware = malware_files.size()
	var score = int((correct_flags * 100.0) / attempts)
	popup_label.text = "Final Score: %d%%\n Correct: %d\n Incorrect: %d" % [score, correct_flags, incorrect_flags]
	popup.popup_centered()

#func reset_flags():
#	for button in file_buttons:
#		button.set_meta("flagged", false)
#		button.get_node("Flag").visible = false


func _on_continue_2_pressed() -> void:
	$intro2.hide()
	$intro3.hide()
	$Continue2.hide()
	$Label.hide()
