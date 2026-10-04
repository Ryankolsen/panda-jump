extends GutTest

# Issue #24: Leaderboard keeps the top tuning.leaderboard_size scores,
# highest first, with 1-based ranks returned from submit(). Pure logic —
# no scene or Node dependency.

func test_submit_on_empty_board_returns_rank_one():
	var board := Leaderboard.new(Tuning.new())
	var rank := board.submit(120, "🐼")
	assert_eq(rank, 1, "the first submit on an empty board ranks first")
	assert_eq(board.entries(), [{"score": 120, "emoji": "🐼"}], "entries holds the one submission")


func test_submits_are_kept_sorted_highest_first():
	var board := Leaderboard.new(Tuning.new())
	board.submit(100, "🐼")
	board.submit(300, "🐼")
	var rank := board.submit(200, "🐼")
	var scores := []
	for entry in board.entries():
		scores.append(entry["score"])
	assert_eq(scores, [300, 200, 100], "entries stay sorted highest score first")
	assert_eq(rank, 2, "200 ranks second behind 300 and ahead of 100")


func test_board_is_trimmed_to_leaderboard_size():
	var board := Leaderboard.new(Tuning.new())
	for score in [10, 20, 30, 40, 50, 60]:
		board.submit(score, "🐼")
	assert_eq(board.entries().size(), 5, "board never exceeds leaderboard_size (5)")
	var scores := []
	for entry in board.entries():
		scores.append(entry["score"])
	assert_false(scores.has(10), "the lowest score was dropped once the board was full")


func test_full_board_rejects_scores_not_strictly_higher_than_the_lowest():
	var board := Leaderboard.new(Tuning.new())
	for score in [50, 60, 70, 80, 90]:
		board.submit(score, "🐼")
	var tie_rank := board.submit(50, "🐼")
	var lower_rank := board.submit(10, "🐼")
	assert_eq(tie_rank, -1, "a score equal to the lowest entry does not rank on a full board")
	assert_eq(lower_rank, -1, "a score below the lowest entry does not rank on a full board")
	assert_eq(board.entries().size(), 5, "rejected submits leave the board unchanged")
	var higher_rank := board.submit(51, "🐼")
	assert_eq(higher_rank, 5, "a score strictly above the lowest entry ranks last (5th)")


func test_tie_goes_below_the_existing_entry():
	var board := Leaderboard.new(Tuning.new())
	board.submit(200, "🦊")
	var rank := board.submit(200, "🐸")
	assert_eq(rank, 2, "a tied score ranks directly below the existing entry")
	assert_eq(board.entries()[0]["emoji"], "🦊", "the older tied entry keeps the higher rank")
	assert_eq(board.entries()[1]["emoji"], "🐸", "the newer tied entry sits below it")


func test_zero_or_negative_score_never_ranks():
	var board := Leaderboard.new(Tuning.new())
	var rank := board.submit(0, "🐼")
	assert_eq(rank, -1, "a score of 0 never ranks, even on an empty board")
	assert_eq(board.entries(), [], "the board is unchanged by a rejected submit")

	var negative_rank := board.submit(-5, "🐼")
	assert_eq(negative_rank, -1, "a negative score never ranks")
	assert_eq(board.entries(), [], "the board is still unchanged")


func test_best_returns_zero_when_empty_and_top_score_otherwise():
	var board := Leaderboard.new(Tuning.new())
	assert_eq(board.best(), 0, "best() is 0 on an empty board")
	board.submit(100, "🐼")
	board.submit(300, "🐼")
	assert_eq(board.best(), 300, "best() returns the top score")


func test_entries_returns_a_copy_not_a_live_reference():
	var board := Leaderboard.new(Tuning.new())
	board.submit(100, "🐼")
	var first := board.entries()
	first.append({"score": 999, "emoji": "🐼"})
	var second := board.entries()
	assert_eq(second.size(), 1, "mutating a returned entries() array does not change the board")


func test_custom_leaderboard_size_caps_the_board():
	var tuning := Tuning.new()
	tuning.leaderboard_size = 3
	var board := Leaderboard.new(tuning)
	for score in [10, 20, 30, 40]:
		board.submit(score, "🐼")
	assert_eq(board.entries().size(), 3, "a custom leaderboard_size of 3 caps the board at 3 entries")
