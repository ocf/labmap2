extends Control

signal fade_complete(tween, log_label)

const MAX_LOG_ENTRIES = 5  # Maximum number of logs to display
const FADE_DURATION = 3.0  # Duration of fade-out in seconds

var logs_to_fade = []

func _ready():
	refresh_logs()

func refresh_logs():
	# Get the most recent logs
	var recent_logs = Logger.logs.slice(-1, MAX_LOG_ENTRIES, -1)
	#$LogContainer.clear_children()
	logs_to_fade.clear()
	for log_entry in recent_logs:
		add_log_entry(log_entry)

func add_log_entry(log_entry: Dictionary):
	# Create a new Label for the log entry
	var log_label = Label.new()
	log_label.text = "[%s][%s]: %s" % [
		log_entry["category"],
		log_entry["device"],
		log_entry["message"]
	]
	$LogContainer.add_child(log_label)
	
	# Fade out the log entry after a delay
	fade_out_log(log_label)

func fade_out_log(log_label: Label):
	var tween = get_tree().create_tween()
	tween.tween_property(log_label, "modulate:a", 1.0, FADE_DURATION)
	tween.tween_property(log_label, "modulate:a", 0.0, FADE_DURATION)
	logs_to_fade.append(tween)
	# Remove the label once the fade is complete
	emit_signal("fade_complete", tween, log_label)

func _on_fade_complete(tween, log_label):
	# this erases too early
	logs_to_fade.erase(tween)
	if is_instance_valid(log_label):
		$LogContainer.remove_child(log_label)

func _on_logger_new_log(log_entry: Dictionary) -> void:
	add_log_entry(log_entry)
