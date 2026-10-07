extends CharacterBody2D

@onready var anim_sprite: AnimatedSprite2D = $AnimatedSprite2D

const SPEED = 230
const JUMP_FORCE = -350
const GRAVITY = 20


func _ready() -> void:
	add_to_group("player")

func _physics_process(_delta: float) -> void:
	# Gravity
	if not is_on_floor():
		velocity.y += GRAVITY

	# Movement input
	var direction = Input.get_axis("ui_left", "ui_right")
	velocity.x = direction * SPEED

	# Flip sprite based on direction
	if direction != 0:
		anim_sprite.flip_h = direction < 0

	# Jump
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_FORCE

	# Movement
	move_and_slide()

	# Handle animations
	if not is_on_floor():
		anim_sprite.play("Jump")
	elif direction != 0:
		anim_sprite.play("Walk")
	else:
		anim_sprite.play("Idle")
