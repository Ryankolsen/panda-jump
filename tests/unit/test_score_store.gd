extends GutTest

# Issue #27: ScoreStore is the only code that touches disk. It saves plain
# data with Godot's ConfigFile, defensively: any missing, corrupt, or
# wrongly-typed data on load comes back as [] rather than erroring.

var _path: String


func before_each():
	_path = "user://test_scores_%d.cfg" % randi()


func after_each():
	DirAccess.remove_absolute(ProjectSettings.globalize_path(_path))


func test_save_then_load_round_trips_the_entries():
	var data := [{"score": 300, "emoji": "🐼"}]
	ScoreStore.new(_path).save_data(data)
	var loaded := ScoreStore.new(_path).load_data()
	assert_eq(loaded, data, "a fresh ScoreStore on the same path reads back what was saved")


func test_load_with_no_file_returns_empty_array():
	var loaded := ScoreStore.new(_path).load_data()
	assert_eq(loaded, [], "loading from a path with no file returns an empty array, not an error")


func test_load_with_garbage_file_returns_empty_array():
	var absolute_path := ProjectSettings.globalize_path(_path)
	var file := FileAccess.open(absolute_path, FileAccess.WRITE)
	file.store_string("{{{ not a config")
	file.close()
	var loaded := ScoreStore.new(_path).load_data()
	assert_eq(loaded, [], "a garbage/corrupt file loads as an empty array")


func test_load_with_entries_as_wrong_type_returns_empty_array():
	var config := ConfigFile.new()
	config.set_value("leaderboard", "entries", "oops")
	config.save(_path)
	var loaded := ScoreStore.new(_path).load_data()
	assert_eq(loaded, [], "a leaderboard/entries value that isn't an Array loads as an empty array")


func test_save_preserves_an_unrelated_section_already_present():
	var config := ConfigFile.new()
	config.set_value("player", "x", 1)
	config.save(_path)

	ScoreStore.new(_path).save_data([{"score": 50, "emoji": "🐼"}])

	var reloaded := ConfigFile.new()
	reloaded.load(_path)
	assert_eq(reloaded.get_value("player", "x"), 1, "save_data does not clobber an unrelated section/key")
