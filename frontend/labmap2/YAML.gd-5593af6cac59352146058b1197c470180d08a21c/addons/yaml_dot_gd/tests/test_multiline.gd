extends Node

# Test multiline YAML parsing
func run() -> bool:
	var parser = YAMLParser.new()
	var test_count = 0
	var success_count = 0
	var f_tmp
	
	# Test 1: Literal block
	f_tmp = FileAccess.open(
		"res://addons/yaml_dot_gd/tests/yamls/multiline/test_01.yaml",
		FileAccess.READ)
	var yaml1 = f_tmp.get_as_text()
	f_tmp.close()
	
	var expected1 = {
		"script": "function hello() {\n  print(\"Hello World!\");\n  print(\"Hello World!\");\n}\n"
	}
	test_count += 1
	var result1 = parser.parse(yaml1)
	if result1 == expected1:
		success_count += 1
		print("Test 1: PASSED - Literal block")
	else:
		print("Test 1: FAILED")
		print("Expected: ", expected1)
		print("Got: ", result1)
	
	# Test 2: Folded block
	f_tmp = FileAccess.open(
		"res://addons/yaml_dot_gd/tests/yamls/multiline/test_02.yaml",
		FileAccess.READ)
	var yaml2 = f_tmp.get_as_text()
	f_tmp.close()
	
	var expected2 = {
		"description": "This is a long description that will be folded into a single paragraph.\n"
	}
	test_count += 1
	var result2 = parser.parse(yaml2)
	if result2 == expected2:
		success_count += 1
		print("Test 2: PASSED - Folded block")
	else:
		print("Test 2: FAILED")
		print("Expected: ", expected2)
		print("Got: ", result2)
		
	# Test 3: Strip chomping
	f_tmp = FileAccess.open(
		"res://addons/yaml_dot_gd/tests/yamls/multiline/test_03.yaml",
		FileAccess.READ)
	var yaml3 = f_tmp.get_as_text()
	f_tmp.close()
	
	var expected3 = {
		"content": "No trailing newline"
	}
	test_count += 1
	var result3 = parser.parse(yaml3)
	if result3 == expected3:
		success_count += 1
		print("Test 3: PASSED - Strip chomping")
	else:
		print("Test 3: FAILED")
		print("Expected: ", expected3)
		print("Got: ", result3)
	
	# Test 4: Keep chomping
	f_tmp = FileAccess.open(
		"res://addons/yaml_dot_gd/tests/yamls/multiline/test_04.yaml",
		FileAccess.READ)
	var yaml4 = f_tmp.get_as_text()
	f_tmp.close()
	
	var expected4 = {
		"content": "line 1\nline 2\n\n\n\n"
	}
	test_count += 1
	var result4 = parser.parse(yaml4)
	if result4 == expected4:
		success_count += 1
		print("Test 4: PASSED - Keep chomping")
	else:
		print("Test 4: FAILED")
		print("Expected: ", expected4)
		print("Got: ", result4)
	
	# Test 5: Quoted string
	f_tmp = FileAccess.open(
		"res://addons/yaml_dot_gd/tests/yamls/multiline/test_05.yaml",
		FileAccess.READ)
	var yaml5 = f_tmp.get_as_text()
	f_tmp.close()
	
	var expected5 = {
		"message": "Line 1\nLine 2\tIndented"
	}
	test_count += 1
	var result5 = parser.parse(yaml5)
	if result5 == expected5:
		success_count += 1
		print("Test 5: PASSED - Quoted string")
	else:
		print("Test 5: FAILED")
		print("Expected: ", expected5)
		print("Got: ", result5)
	
	print("Multiline Tests: %d/%d passed" % [success_count, test_count])
	return success_count == test_count
