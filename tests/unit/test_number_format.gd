extends GutTest

# Issue #23: NumberFormat.thousands groups digits with ',' for the score
# display. Static and pure so the formatting rule is testable without a
# scene tree.

func test_thousands_at_zero():
	assert_eq(NumberFormat.thousands(0), "0", "thousands at zero stays '0'")


func test_thousands_below_one_thousand():
	assert_eq(NumberFormat.thousands(999), "999", "no separator below 1000")


func test_thousands_at_one_thousand():
	assert_eq(NumberFormat.thousands(1000), "1,000", "separator appears at 1000")


func test_thousands_four_digits():
	assert_eq(NumberFormat.thousands(1240), "1,240", "groups of 3 from the right")


func test_thousands_millions():
	assert_eq(NumberFormat.thousands(1234567), "1,234,567", "multiple separators")


func test_thousands_negative():
	assert_eq(NumberFormat.thousands(-1240), "-1,240", "leading '-' kept before grouped digits")
