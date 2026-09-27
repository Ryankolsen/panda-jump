extends GutTest

# Issue #10: the Game Over screen's copy is kept in a static, pure function
# so it's testable without a scene tree — see GameOver.lines_for.

func test_lines_for_has_three_entries():
	var lines: Array[String] = GameOver.lines_for(250)
	assert_eq(lines.size(), 3, "the screen shows exactly three lines")


func test_lines_for_content():
	var lines: Array[String] = GameOver.lines_for(250)
	assert_eq(lines, ["Game Over", "Score: 250", "Tap to play again"], "exact copy and final score")


func test_lines_for_zero_score():
	var lines: Array[String] = GameOver.lines_for(0)
	assert_eq(lines[1], "Score: 0", "a zero score still reads Score: 0")
