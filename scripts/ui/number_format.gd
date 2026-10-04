class_name NumberFormat
extends RefCounted

## Pure number-formatting helpers, kept free of any Node/scene dependency
## so they're testable without a scene tree.


## Formats `value` with ',' separating groups of 3 digits, counted from the
## right (e.g. 1240 -> "1,240", 1234567 -> "1,234,567"). Negative values
## keep a leading '-' before the grouped digits (-1240 -> "-1,240").
static func thousands(value: int) -> String:
	var sign := ""
	var magnitude := value
	if magnitude < 0:
		sign = "-"
		magnitude = -magnitude

	var digits := str(magnitude)
	var grouped := ""
	var count := 0
	for i in range(digits.length() - 1, -1, -1):
		grouped = digits[i] + grouped
		count += 1
		if count % 3 == 0 and i != 0:
			grouped = "," + grouped

	return sign + grouped
