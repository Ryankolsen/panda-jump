extends GutTest

# Issue #30: the Game Over card's emoji (the board's emoji column now, the
# picker buttons in the next slice) only render if the bundled emoji font
# is wired in as a fallback on GameOver.card_font() — see that function's
# doc comment for why it's a FontVariation rather than a per-label override.

const EMOJI_FONT_PATH := "res://assets/fonts/emoji_subset.ttf"


func test_card_font_falls_back_to_emoji_font():
	var emoji_font: Font = load(EMOJI_FONT_PATH)
	assert_true(GameOver.card_font().fallbacks.has(emoji_font), "card_font() should list the emoji font as a fallback")


func test_emoji_font_has_every_picker_emoji():
	var emoji_font: Font = load(EMOJI_FONT_PATH)
	for e in Leaderboard.PICKER_EMOJI:
		assert_true(emoji_font.has_char(e.unicode_at(0)), "emoji font is missing glyph for %s" % e)


func test_card_font_still_renders_normal_text():
	assert_true(GameOver.card_font().has_char("A".unicode_at(0)), "card_font() should still render plain ASCII text")
