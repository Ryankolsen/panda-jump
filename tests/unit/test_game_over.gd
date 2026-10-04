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
