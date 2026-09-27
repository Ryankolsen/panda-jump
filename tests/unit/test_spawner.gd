extends GutTest

# Issue #7: Spawner rolls in barrels with gaps a normal jump can always
# clear. Seeded by the caller so tests (and replays) are reproducible.

func _spawner(seed: int) -> Spawner:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed
	return Spawner.new(Tuning.new(), rng)


func test_next_returns_a_barrel_kind():
	var spawner := _spawner(1)
	var result: Dictionary = spawner.next(140.0)
	assert_eq(result.kind, Spawner.Kind.BARREL, "next() spawns a barrel for now")


func test_min_barrel_gap_matches_air_time_plus_landing_time():
	var spawner := _spawner(1)
	var expected := 140.0 * (2.0 * 520.0 / 1400.0 + 0.45)
	assert_almost_eq(spawner.min_barrel_gap(140.0), expected, 0.1, "min gap comes from air time + landing time")


func test_every_offset_stays_within_the_fair_gap_window():
	var spawner := _spawner(1)
	var min_gap := spawner.min_barrel_gap(140.0)
	var max_gap := min_gap + 220.0
	for i in range(500):
		var result: Dictionary = spawner.next(140.0)
		assert_gte(result.offset, min_gap, "offset %d is at least the fair minimum" % i)
		assert_lte(result.offset, max_gap, "offset %d is at most min + barrel_gap_extra" % i)


func test_same_seed_produces_the_same_sequence():
	var a := _spawner(42)
	var b := _spawner(42)
	for i in range(50):
		assert_eq(a.next(140.0), b.next(140.0), "seed 42 reproduces the same result at step %d" % i)


func test_different_seed_produces_a_different_sequence():
	var a := _spawner(42)
	var b := _spawner(43)
	var differs := false
	for i in range(50):
		var result_a: Dictionary = a.next(140.0)
		var result_b: Dictionary = b.next(140.0)
		if result_a.offset != result_b.offset:
			differs = true
	assert_true(differs, "seed 43 diverges from seed 42 somewhere in 50 results")


func test_offsets_stay_fair_at_a_higher_speed():
	var spawner := _spawner(1)
	var min_gap := spawner.min_barrel_gap(300.0)
	for i in range(500):
		var result: Dictionary = spawner.next(300.0)
		assert_gte(result.offset, min_gap, "offset %d is at least the fair minimum at 300 px/s" % i)
