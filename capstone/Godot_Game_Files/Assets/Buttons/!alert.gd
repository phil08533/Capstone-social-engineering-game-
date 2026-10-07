extends Area2D
## The floating "!" above a computer. When active and the player stands in it,
## pressing "interact" emits `activated`; the level decides what that opens.

signal activated

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var prompt: Label = $AlertLabel

var player_in_area := false


func _ready() -> void:
	sprite.play("float")


func _unhandled_input(event: InputEvent) -> void:
	if player_in_area and event.is_action_pressed("interact"):
		get_viewport().set_input_as_handled()
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
