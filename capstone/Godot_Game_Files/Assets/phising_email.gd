extends Node2D
## Phishing-email puzzle. The player accepts or rejects a suspicious email.
## Every email in `messages` is a phishing attempt, so rejecting is correct.

## Emitted once the player has read the feedback and clicked Continue.
signal finished

const REWARD := 100


var messages = [
		"""
Dear Valued Customer,
We noticed suspicious activity on your account of magical creatures.
Please confirm your rainbow code and billing at [FAKE-LINK] immediately.
Failure to respond will result in loss of your sparkles.
Click the glowing button to avoid disappointment.
Sincerely, The Unicorn Billing Team
""",
		"""
Hi Team,
Payroll encountered a tiny gremlin causing deposits to move to a different planet.
To re-route your pay, reply with your bank routing number and "magical code."
We promise this is secure (definitely).
Thanks for your cooperation, Payroll Ops
""",
		"""
Dear User,
We tried to send you a message but your mailbox is full of confetti.
Click [FAKE-LINK] to clear the confetti and verify your account now.
If you do nothing, a mysterious raccoon will take your username.
Cheers, Account Preservation Squad
""",
		"""
Hey,
It's me, your coworker (maybe). I'm stranded on the moon and need $200.
Please Venmo to @moon-rescue or reply with card details.
I'll pay you back with lunar selfies.
Thanks!!
"""
	]

var emails = ["""hotdogwarrior@hotdot.com""","""hr@workofice.com""","""dragonmaster302@yawho.com""","""gregk@worckoffice.com""","""Ilostmyhat@hatlover.com"""]

@onready var accept_button: BaseButton = $Button_manager/Accept
@onready var reject_button: BaseButton = $Button_manager/Reject
@onready var help_button: BaseButton = $Button_manager/Help
@onready var continue_button: BaseButton = $Button_manager/Continue
@onready var help_label: Label = $Button_manager/Help/Label
@onready var feedback_label: Label = $Button_manager/Continue/Label2
@onready var camera: Camera2D = $phisingemailcamera2d


func _ready() -> void:
	_reset()


## Shows a fresh email and takes over the camera.
func start() -> void:
	_reset()
	camera.make_current()


func _reset() -> void:
	_show_random_email()
	accept_button.visible = true
	reject_button.visible = true
	help_button.visible = true
	continue_button.visible = false
	help_label.visible = false
	help_label.text = "⚠️ Watch for common phishing signs:
• Urgent or threatening language
• Requests for passwords or payment info
• Strange links or unknown senders
• Poor spelling, odd formatting, or suspicious attachments
Never share sensitive info through email.
"


func _show_random_email() -> void:
	$PhisingEmail/message.text = messages.pick_random()
	$PhisingEmail/email.text = "FROM: " + emails.pick_random()


func _show_feedback(text: String) -> void:
	feedback_label.text = text
	accept_button.visible = false
	reject_button.visible = false
	help_button.visible = false
	continue_button.visible = true


func _on_accept_pressed() -> void:
	Global.score -= REWARD
	_show_feedback("WRONG! Never trust an email asking for credit card information.
	Always look who is sending it and make sure you know them.")


func _on_reject_pressed() -> void:
	Global.score += REWARD
	_show_feedback("CORRECT! Never trust an email asking for credit card information.
	Always look who is sending it and make sure you know them.")


func _on_continue_pressed() -> void:
	finished.emit()


func _on_help_pressed() -> void:
	help_label.visible = !help_label.visible
