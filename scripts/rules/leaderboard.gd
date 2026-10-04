class_name Leaderboard
extends RefCounted

## The top tuning.leaderboard_size scores, highest first. Pure logic — not
## connected to the game yet. Each entry is a Dictionary {"score": int,
## "emoji": String}.
##
## No reset method: restarting a run reloads the scene (#10), which builds
## a new Leaderboard.

const DEFAULT_EMOJI := "🐼"

var _size: int
var _entries: Array[Dictionary] = []


func _init(tuning: Tuning) -> void:
	_size = tuning.leaderboard_size


## Inserts score/emoji into the board if it ranks, keeping entries sorted
## highest score first and trimmed to the board size. Ties go below an
## existing equal score, so an older entry keeps the higher rank. Returns
## the 1-based rank the entry landed at, or -1 if it didn't make the board
## (score <= 0, or not strictly higher than the lowest entry on a full
## board) — in which case the board is left unchanged.
func submit(score: int, emoji: String) -> int:
	if score <= 0:
		return -1

	var index := 0
	while index < _entries.size() and _entries[index]["score"] >= score:
		index += 1

	if index >= _size:
		return -1

	_entries.insert(index, {"score": score, "emoji": emoji})
	if _entries.size() > _size:
		_entries.resize(_size)

	return index + 1


## The board in rank order, as a copy — mutating the returned array or its
## entries does not change the board.
func entries() -> Array[Dictionary]:
	return _entries.duplicate(true)


## The top score, or 0 when the board is empty.
func best() -> int:
	if _entries.is_empty():
		return 0
	return _entries[0]["score"]
