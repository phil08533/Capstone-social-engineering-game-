extends Node
## Game-wide state shared between the office level and the puzzles.

signal score_changed(new_score: int)

var score: int = 0:
	set(value):
		score = value
		score_changed.emit(score)


## Called whenever a new run starts so nothing leaks over from a previous one.
func reset() -> void:
	score = 0
	Dialogic.VAR.chatstep = 0
