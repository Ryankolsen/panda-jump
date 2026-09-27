extends GutTest

# Issue #16: SpriteFit computes a uniform scale that makes a picture a given
# target height, keeping proportions, so barrel, bamboo and panda all share
# the same scale-to-height math instead of each doing it themselves.


func test_scale_for_core_wiring():
	assert_eq(SpriteFit.scale_for(Vector2(297, 512), 64.0), Vector2(0.125, 0.125))


func test_scale_for_keeps_proportions():
	var result := SpriteFit.scale_for(Vector2(100, 50), 28.0)
	assert_almost_eq(result.x, 0.56, 0.0001)
	assert_almost_eq(result.y, 0.56, 0.0001)


func test_scale_for_zero_height_returns_one():
	assert_eq(SpriteFit.scale_for(Vector2(10, 0), 28.0), Vector2.ONE)
