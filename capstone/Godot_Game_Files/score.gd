extends Label


func _ready() -> void:
	Global.score_changed.connect(_update)
	_update(Global.score)


func _update(value: int) -> void:
	text = "score: $" + str(value)
