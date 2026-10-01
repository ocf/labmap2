extends Node
class_name TestAdvanced

# Test advanced YAML features
func run() -> bool:
	var parser = YAMLParser.new()
	var test_count = 0
	var success_count = 0
	var f_tmp

	# Test 1: Complex nested structure
	f_tmp = FileAccess.open(
		"res://addons/yaml_dot_gd/tests/yamls/advanced/test_01.yaml",
		FileAccess.READ)
	var yaml1 = f_tmp.get_as_text()
	f_tmp.close()

	var expected1 = {
		"player": {
			"name": "Hero",
			"stats": {
				"health": 100,
				"mana": 50
			},
			"inventory": [
				"sword",
				"shield",
				{
					"name": "Health Potion",
					"value": 25
				}
			]
		}
	}
	test_count += 1
	var result1 = parser.parse(yaml1)
	if result1 == expected1:
		success_count += 1
		print("Test 1: PASSED - Complex nested structure")
	else:
		print("Test 1: FAILED")
		print("Expected: ", expected1)
		print("Got: ", result1)

	# Test 2: Multiple levels of nesting
	f_tmp = FileAccess.open(
		"res://addons/yaml_dot_gd/tests/yamls/advanced/test_02.yaml",
		FileAccess.READ)
	var yaml2 = f_tmp.get_as_text()
	f_tmp.close()

	var expected2 = {
		"level1": {
			"level2": {
				"level3": {
					"key": "value"
				},
				"list": ["item1", "item2"]
			}
		}
	}
	test_count += 1
	var result2 = parser.parse(yaml2)
	if result2 == expected2:
		success_count += 1
		print("Test 2: PASSED - Multiple levels of nesting")
	else:
		print("Test 2: FAILED")
		print("Expected: ", expected2)
		print("Got: ", result2)

	# Test 3: Mixed list types
	f_tmp = FileAccess.open(
		"res://addons/yaml_dot_gd/tests/yamls/advanced/test_03.yaml",
		FileAccess.READ)
	var yaml3 = f_tmp.get_as_text()
	f_tmp.close()

	var expected3 = {
		"items": [
			"string",
			42,
			true,
			{"key": "value"},
			[1, 2, 3]
		]
	}
	test_count += 1
	var result3 = parser.parse(yaml3)
	if result3 == expected3:
		success_count += 1
		print("Test 3: PASSED - Mixed list types")
	else:
		print("Test 3: FAILED")
		print("Expected: ", expected3)
		print("Got: ", result3)

	# Test 4: Comments and empty lines
	f_tmp = FileAccess.open(
		"res://addons/yaml_dot_gd/tests/yamls/advanced/test_04.yaml",
		FileAccess.READ)
	var yaml4 = f_tmp.get_as_text()
	f_tmp.close()
	
	var expected4 = {
		"config": {
			"resolution": "1920x1080",
			"volume": 80,
			"mute": false
		}
	}
	test_count += 1
	var result4 = parser.parse(yaml4)
	if result4 == expected4:
		success_count += 1
		print("Test 4: PASSED - Comments and empty lines")
	else:
		print("Test 4: FAILED")
		print("Expected: ", expected4)
		print("Got: ", result4)

	# Test 5: Colons in values
	f_tmp = FileAccess.open(
		"res://addons/yaml_dot_gd/tests/yamls/advanced/test_05.yaml",
		FileAccess.READ)
	var yaml5 = f_tmp.get_as_text()
	f_tmp.close()
	
	var expected5 = {
		"url": "https://example.com",
		"time": "12:30:45"
	}
	test_count += 1
	var result5 = parser.parse(yaml5)
	if result5 == expected5:
		success_count += 1
		print("Test 5: PASSED")
	else:
		print("Test 5: FAILED")
		print("Expected: ", expected5)
		print("Got: ", result5)

	print("Advanced Tests: %d/%d passed" % [success_count, test_count])
	return success_count == test_count
