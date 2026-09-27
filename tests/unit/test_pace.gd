extends GutTest

# Issue #3: Pace advances distance from Tuning's start_speed via tick(delta).
# Time only moves through tick — no _process, no scene dependencies.

func test_speed_comes_from_tuning_before_any_tick():
	var pace := Pace.new(Tuning.new())
	assert_eq(pace.speed, 140.0, "speed matches Tuning.start_speed before any tick")


func test_tick_accumulates_distance_over_multiple_calls():
	var pace := Pace.new(Tuning.new())
	pace.tick(0.5)
	pace.tick(0.25)
	assert_almost_eq(pace.distance, 140.0 * 0.75, 0.001, "distance is speed * elapsed time across ticks")


func test_speed_reads_from_tuning_not_hard_coded():
	var tuning := Tuning.new()
	tuning.start_speed = 200.0
	var pace := Pace.new(tuning)
	assert_eq(pace.speed, 200.0, "Pace reads tuning's start_speed, not a hard-coded number")


func test_tick_with_zero_delta_leaves_distance_unchanged():
	var pace := Pace.new(Tuning.new())
	pace.tick(0.0)
	assert_eq(pace.distance, 0.0, "a zero-delta tick advances nothing")
