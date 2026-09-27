extends GutTest

# Issue #9: Hud.score_text formats the on-screen score label. Static and
# pure so the text rule is testable without a scene tree.

func test_score_text_formats_score():
	assert_eq(Hud.score_text(123), "Score: 123", "score_text reads 'Score: N'")


func test_score_text_at_zero():
	assert_eq(Hud.score_text(0), "Score: 0", "score_text works at zero score")
