extends CanvasLayer
## On-screen buttons for phones and tablets: move left/right, jump and interact.
##
## Touches are handled here directly (rather than through Button nodes) so that
## several fingers can be held at once, e.g. walking while jumping.

const BUTTONS := [
	{"label": "<", "action": "ui_left", "rect": Rect2(30, 500, 120, 120)},
	{"label": ">", "action": "ui_right", "rect": Rect2(170, 500, 120, 120)},
	{"label": "E", "action": "interact", "rect": Rect2(860, 500, 120, 120)},
	{"label": "^", "action": "ui_accept", "rect": Rect2(1000, 500, 120, 120)},
]

var _touch_actions := {}  # finger index -> action it is holding
var _panels := {}  # action -> Panel


func _ready() -> void:
	layer = 5
	for button in BUTTONS:
		var panel := Panel.new()
		panel.position = button.rect.position
		panel.size = button.rect.size
		panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
		panel.modulate = Color(1, 1, 1, 0.45)
		var label := Label.new()
		label.text = button.label
		label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label.add_theme_font_size_override("font_size", 48)
		label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		panel.add_child(label)
		add_child(panel)
		_panels[button.action] = panel


## Show or hide the controls. Hiding releases anything currently held.
func set_enabled(enabled: bool) -> void:
	visible = enabled and DisplayServer.is_touchscreen_available()
	if not enabled:
		for finger in _touch_actions.keys():
			_release(finger)


func _input(event: InputEvent) -> void:
	if not visible:
		return
	if event is InputEventScreenTouch:
		if event.pressed:
			_press(event.index, _action_at(event.position))
		else:
			_release(event.index)
	elif event is InputEventScreenDrag:
		var action := _action_at(event.position)
		if _touch_actions.get(event.index, "") != action:
			_release(event.index)
			_press(event.index, action)


## Touch positions are already in the game's stretched (virtual) coordinates.
func _action_at(pos: Vector2) -> String:
	for button in BUTTONS:
		if button.rect.has_point(pos):
			return button.action
	return ""


func _press(finger: int, action: String) -> void:
	if action == "":
		return
	_touch_actions[finger] = action
	_send(action, true)


func _release(finger: int) -> void:
	if not _touch_actions.has(finger):
		return
	_send(_touch_actions[finger], false)
	_touch_actions.erase(finger)


func _send(action: String, pressed: bool) -> void:
	if pressed:
		Input.action_press(action)
	else:
		Input.action_release(action)
	_panels[action].modulate.a = 0.8 if pressed else 0.45
