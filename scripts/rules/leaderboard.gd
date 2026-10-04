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


## Points `score` still needs to rank on the board. If a slot is empty,
## the threshold to rank is 1 (any positive score ranks; 0 never does). If
## the board is full, the threshold is one more than the lowest entry's
## score, since a tie goes below an existing entry rather than ranking
## (see submit()). Returns 0 when `score` already meets the threshold.
func gap_to_board(score: int) -> int:
	var threshold: int
	if _entries.size() < _size:
		threshold = 1
	else:
		threshold = _entries[_entries.size() - 1]["score"] + 1
	return maxi(threshold - score, 0)


## The board's configured capacity (tuning.leaderboard_size), so callers
## building a fixed number of display rows — see GameOver.board_rows —
## don't need a second reference to the Tuning this board was built from.
func size() -> int:
	return _size


## The board as plain data ({"score": int, "emoji": String} Dictionaries, in
## rank order), ready to hand to ScoreStore.save_data(). Same copy semantics
## as entries().
func to_data() -> Array:
	return entries()


## Replaces the board from previously-saved plain data, defensively: a
## non-Array argument is ignored (board left empty); elements that aren't a
## Dictionary, have no int "score", or have "score" <= 0 are skipped;
## a missing or non-String "emoji" becomes DEFAULT_EMOJI. The result is
## re-sorted highest score first, preserving saved order between equal
## scores, and trimmed to _size.
func load_data(data: Variant) -> void:
	_entries.clear()
	if not data is Array:
		return

	# Each valid element keeps its original index alongside it so the sort
	# below — Array.sort_custom's stability isn't documented/guaranteed —
	# can break score ties by that index instead, which is what actually
	# preserves saved order between equal scores.
	var valid: Array[Dictionary] = []
	for index in data.size():
		var element: Variant = data[index]
		if not element is Dictionary:
			continue
		if not element.has("score") or not element["score"] is int:
			continue
		if element["score"] <= 0:
			continue

		var emoji: String = DEFAULT_EMOJI
		if element.has("emoji") and element["emoji"] is String:
			emoji = element["emoji"]

		valid.append({"score": element["score"], "emoji": emoji, "_index": index})

	valid.sort_custom(func(a, b):
		if a["score"] != b["score"]:
			return a["score"] > b["score"]
		return a["_index"] < b["_index"]
	)
	valid.resize(mini(valid.size(), _size))

	_entries = []
	for entry in valid:
		_entries.append({"score": entry["score"], "emoji": entry["emoji"]})
