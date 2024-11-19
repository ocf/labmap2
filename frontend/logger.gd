extends Node

signal new_log(log_entry: Dictionary)

var logs: Array = []  # Store logs in an array

func log(message: String, category: String = "info", device_name: String = ""):
	var timestamp = Time.get_time_string_from_system()
	var log_entry = {
		"timestamp": timestamp,
		"category": category,
		"message": message,
		"device": device_name
	}
	logs.append(log_entry)
	emit_signal("new_log", log_entry)
	#print("[%s][%s][%s]: %s" % [category.capitalize(), device_name, timestamp, message])  # Optional: Print log in console

func get_logs(_filter_category: String = "") -> Array:
	#if filter_category == "":
	return logs
	#return logs.filter(lambda(entry): entry.category == filter_category)
