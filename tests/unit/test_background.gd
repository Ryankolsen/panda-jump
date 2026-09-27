extends GutTest

# Issue #4: ForestBackground's scroll math is testable without a scene.
# One tile is 630px wide; mirrored pairs (odd copies flipped) repeat every
# 2 copies, so the wrap period is 2 * tile_width = 1260.

func test_scroll_offset_at_zero_distance():
	assert_eq(ForestBackground.scroll_offset(0.0, 630.0), 0.0, "no distance travelled means no offset")


func test_scroll_offset_within_and_beyond_one_mirrored_pair():
	assert_almost_eq(ForestBackground.scroll_offset(700.0, 630.0), 700.0, 0.001, "still within the first mirrored pair (< 1260)")
	assert_almost_eq(ForestBackground.scroll_offset(1300.0, 630.0), 40.0, 0.001, "wraps at 1260 (2 * tile_width)")


func test_is_mirrored_alternates_by_copy_index():
	assert_eq(ForestBackground.is_mirrored(0), false, "copy 0 is not mirrored")
	assert_eq(ForestBackground.is_mirrored(1), true, "copy 1 is mirrored")
	assert_eq(ForestBackground.is_mirrored(2), false, "copy 2 is not mirrored")


func test_scroll_offset_stays_in_range_for_large_distance():
	var offset := ForestBackground.scroll_offset(1_000_000.0, 630.0)
	assert_true(offset >= 0.0 and offset < 1260.0, "offset stays within [0, 2 * tile_width) even for huge distances")
