extends GutTest

# Issue #6: Health tracks hearts, hits, the invincible period after a hit,
# healing, and dying. Pure logic — no scene or Node dependency. Time only
# moves through tick(), matching Pace's shape from #3.

func test_new_health_has_three_hearts():
	var health := Health.new(Tuning.new())
	assert_eq(health.hearts, 3, "a new Health starts at max_hearts (3)")


func test_hit_returns_true_and_leaves_two_hearts_and_invincible():
	var health := Health.new(Tuning.new())
	var result := health.hit()
	assert_true(result, "hit() returns true when it lands")
	assert_eq(health.hearts, 2, "one hit removes one heart from 3")
	assert_true(health.is_invincible(), "a landed hit starts the invincible period")


func test_hit_emits_changed_with_new_heart_count():
	var health := Health.new(Tuning.new())
	watch_signals(health)
	health.hit()
	assert_signal_emitted_with_parameters(health, "changed", [2])


func test_second_hit_during_invincibility_is_ignored():
	var health := Health.new(Tuning.new())
	health.hit()
	var result := health.hit()
	assert_false(result, "a hit while invincible does nothing and returns false")
	assert_eq(health.hearts, 2, "hearts are unchanged by an ignored hit")


func test_invincibility_ends_exactly_at_invincible_time_and_allows_next_hit():
	var health := Health.new(Tuning.new())
	health.hit()
	health.tick(0.99)
	assert_true(health.is_invincible(), "still invincible just before invincible_time elapses")
	health.tick(0.02)
	assert_false(health.is_invincible(), "invincibility ends once invincible_time has elapsed")
	var result := health.hit()
	assert_true(result, "a hit lands again once invincibility has ended")
	assert_eq(health.hearts, 1, "the second landed hit removes another heart")


func test_heal_after_a_hit_returns_to_max_and_emits_changed():
	var health := Health.new(Tuning.new())
	health.hit()
	watch_signals(health)
	health.heal()
	assert_eq(health.hearts, 3, "heal() adds one heart back")
	assert_signal_emitted_with_parameters(health, "changed", [3])


func test_heal_at_full_hearts_stays_capped_and_emits_nothing():
	var health := Health.new(Tuning.new())
	watch_signals(health)
	health.heal()
	assert_eq(health.hearts, 3, "heal() never exceeds max_hearts")
	assert_signal_emit_count(health, "changed", 0, "heal() at full hearts emits no changed signal")


func test_three_hits_kill_and_died_emits_exactly_once_then_fourth_hit_ignored():
	var health := Health.new(Tuning.new())
	watch_signals(health)
	health.hit()
	health.tick(1.0)
	health.hit()
	health.tick(1.0)
	health.hit()
	assert_eq(health.hearts, 0, "three landed hits from 3 hearts reach 0")
	assert_true(health.is_dead(), "is_dead() is true once hearts reach 0")
	assert_signal_emit_count(health, "died", 1, "died is emitted exactly once")
	var result := health.hit()
	assert_false(result, "a hit on a dead Health does nothing and returns false")
	assert_eq(health.hearts, 0, "hearts never go negative")


func test_heal_when_dead_leaves_hearts_at_zero():
	var health := Health.new(Tuning.new())
	health.hit()
	health.tick(1.0)
	health.hit()
	health.tick(1.0)
	health.hit()
	health.heal()
	assert_eq(health.hearts, 0, "heal() does nothing once Health is dead")
