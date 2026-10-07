extends Area2D
## The floating "!" above a computer. When active and the player stands in it,
## pressing "interact" emits `activated`; the level decides what that opens.

signal activated

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var prompt: Label = $AlertLabel

var player_in_area := false


func _ready() -> void:
	sprite.play("float")


# Polled rather than handled as an event so it also works with the on-screen
# touch button, which sets the action state directly.
func _process(_delta: float) -> void:
	if player_in_area and Input.is_action_just_pressed("interact"):
		activated.emit()


## Show or hide the alert. While inactive it cannot be triggered.
func set_active(active: bool) -> void:
	visible = active
	set_deferred("monitoring", active)
	if not active:
		player_in_area = false
		prompt.visible = false


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_area = true
		prompt.visible = true


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_area = false
		prompt.visible = false
