class_name ScoreStore
extends RefCounted

## The only code in this project that touches disk. Everything else (the
## Leaderboard, Main) works with plain in-memory data, which is what keeps
## them pure and easy to test; ScoreStore stays this thin — read, defend,
## write — so the one place that can fail against a real filesystem is also
## the easiest to read in full and the easiest to point a test at a
## temporary path instead of the real user:// file.

const SECTION := "leaderboard"
const KEY := "entries"

var _path: String


func _init(path: String = "user://scores.cfg") -> void:
	_path = path


## The saved entries, or [] if the file is missing, unreadable, corrupt, or
## the key is missing or not an Array. Never errors or crashes — a bad save
## file should lose the board, not the game.
func load_data() -> Array:
	var config := ConfigFile.new()
	var err := config.load(_path)
	if err != OK:
		return []

	var value: Variant = config.get_value(SECTION, KEY, [])
	if not value is Array:
		return []

	return value


## Writes data under "leaderboard/entries", preserving any other
## sections/keys already in the file (e.g. a last-picked emoji saved by a
## later slice).
func save_data(data: Array) -> void:
	var config := ConfigFile.new()
	# A failed load (missing/corrupt file) just means starting from a blank
	# ConfigFile — there is nothing else to preserve in that case.
	config.load(_path)
	config.set_value(SECTION, KEY, data)
	config.save(_path)
