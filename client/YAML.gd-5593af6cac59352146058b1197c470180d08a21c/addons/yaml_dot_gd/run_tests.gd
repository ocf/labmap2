extends Node

func _ready():
	# Create test instances
	var basic_test = load("res://addons/yaml_dot_gd/tests/test_basic.gd").new()
	var multiline_test = load("res://addons/yaml_dot_gd/tests/test_multiline.gd").new()
	var advanced_test = load("res://addons/yaml_dot_gd/tests/test_advanced.gd").new()
	
	# Run tests
	var all_passed = true
	
	print("=== Running Basic Tests ===")
	if !basic_test.run():
		all_passed = false
	print("\n")
	
	print("=== Running Multiline Tests ===")
	if !multiline_test.run():
		all_passed = false
	print("\n")
	
	print("=== Running Advanced Tests ===")
	if !advanced_test.run():
		all_passed = false
	print("\n")
	
	# Final result
	if all_passed:
		print("✅ ALL TESTS PASSED")
	else:
		print("❌ SOME TESTS FAILED")
	
	# Free test objects
	basic_test.free()
	multiline_test.free()
	advanced_test.free()
