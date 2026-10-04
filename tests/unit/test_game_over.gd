extends GutTest

# Issue #26: the Game Over screen's copy is kept in static, pure functions
# so it's testable without a scene tree — see GameOver.run_lines and
# GameOver.board_rows.

func test_run_lines_new_best():
	var lines: Array[String] = GameOver.run_lines(1240, 1)
	assert_eq(lines, ["This run", "1,240", "New best!"], "rank 1 shows the New best! badge")


func test_run_lines_not_best():
	var lines: Array[String] = GameOver.run_lines(1240, 3)
	assert_eq(lines, ["This run", "1,240", ""], "a rank below 1 shows a blank badge line")


func test_run_lines_off_board():
	var lines: Array[String] = GameOver.run_lines(1240, -1)
	assert_eq(lines, ["This run", "1,240", ""], "not making the board shows a blank badge line")


func test_board_rows_one_entry_padded_to_size():
	var rows: Array = GameOver.board_rows([{"score": 1240, "emoji": "🐼"}], 5)
	assert_eq(rows, [
		["1", "🐼", "1,240"],
		["2", "—", "—"],
		["3", "—", "—"],
		["4", "—", "—"],
		["5", "—", "—"],
	], "one real entry then blank slots, ranked and formatted")


func test_board_rows_empty_board():
	var rows: Array = GameOver.board_rows([], 5)
	assert_eq(rows.size(), 5, "always exactly size rows")
	for row in rows:
		assert_eq(row[1], "—", "empty slot shows an em dash for emoji")
		assert_eq(row[2], "—", "empty slot shows an em dash for score")


# Issue #28: missed_lines() gives a run that didn't make the board
# something to aim for — shown under the run score when rank == -1.

func test_missed_lines_formats_best_and_gap():
	var lines: Array[String] = GameOver.missed_lines(1240, 570)
	assert_eq(lines, ["Best: 1,240", "570 to make the board"], "missed_lines formats both numbers with grouping")


func test_missed_lines_on_an_empty_board():
	var lines: Array[String] = GameOver.missed_lines(0, 1)
	assert_eq(lines, ["Best: 0", "1 to make the board"], "an empty board still formats best as 0")


func test_show_game_over_shows_missed_lines_when_off_board():
	var game_over: GameOver = autofree(preload("res://scenes/ui/game_over.tscn").instantiate())
	add_child_autofree(game_over)
	var leaderboard := Leaderboard.new(Tuning.new())
	for score in [1240, 1100, 1050, 1000, 979]:
		leaderboard.submit(score, "🐼")
	game_over.show_game_over(410, leaderboard, -1, 0.0)
	assert_eq(game_over.get_node("Margin/VBox/Columns/Left/RunScore").text, "410", "the run score still shows")
	assert_eq(game_over.get_node("Margin/VBox/Columns/Left/RunBest").text, "Best: 1,240", "the best score shows when the run missed the board")
	assert_eq(game_over.get_node("Margin/VBox/Columns/Left/RunGap").text, "570 to make the board", "the gap to the board shows when the run missed it")
	assert_true(game_over.get_node("Margin/VBox/Columns/Left/RunBest").visible, "RunBest is visible when the run missed the board")
	assert_true(game_over.get_node("Margin/VBox/Columns/Left/RunGap").visible, "RunGap is visible when the run missed the board")


func test_show_game_over_hides_missed_lines_when_ranked():
	var game_over: GameOver = autofree(preload("res://scenes/ui/game_over.tscn").instantiate())
	add_child_autofree(game_over)
	var leaderboard := Leaderboard.new(Tuning.new())
	leaderboard.submit(1240, "🐼")
	game_over.show_game_over(1240, leaderboard, 1, 0.0)
	assert_false(game_over.get_node("Margin/VBox/Columns/Left/RunBest").visible, "RunBest is hidden when the run ranked")
	assert_false(game_over.get_node("Margin/VBox/Columns/Left/RunGap").visible, "RunGap is hidden when the run ranked")
