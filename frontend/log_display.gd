extends Control

signal fade_complete(tween, log_label)

const MAX_LOG_ENTRIES = 5  # Maximum number of logs to display
const FADE_DURATION = 3.0  # Duration of fade-out in seconds

var logs_to_fade = []
var displayed_logs = []

func _ready():
	refresh_logs()

func refresh_logs():
	# Get the most recent logs
	var recent_logs = Logger.logs.slice(-1, MAX_LOG_ENTRIES, -1)
	logs_to_fade.clear()
	for log_entry in recent_logs:
		if log_entry not in displayed_logs:
			add_log_entry(log_entry)

func add_log_entry(log_entry_text: Dictionary):
	displayed_logs.append(log_entry_text)
	
	# Create a new log entry panel
	var log_entry_panel = Panel.new()
	log_entry_panel.name = "LogEntryPanel"
	log_entry_panel.custom_minimum_size = Vector2(450, 23)  # Ensure height
	
	var background_style = StyleBoxFlat.new()
	if log_entry_text["category"] == "Error":
		background_style.bg_color = Color(1, 0.2, 0.2, 1)  # Red for errors
	elif log_entry_text["category"] == "Warning":
		background_style.bg_color = Color(1, 1, 0.2, 1)  # Yellow for warnings
	else:
		background_style.bg_color = Color(0.2, 0.2, 0.2, 1)  # Default dark gray
	background_style.set_border_width_all(2)  # Border thickness
	background_style.border_color = Color(0.5, 0.5, 0.5, 1)  # Light gray border
	log_entry_panel.add_theme_stylebox_override("panel", background_style)
	
	# Create a new Label for the log entry
	var log_entry_label = Label.new()
	log_entry_label.text = "[%s][%s]: %s" % [
		log_entry_text["category"],
		log_entry_text["device"],
		log_entry_text["message"]
	]
	log_entry_label.position = Vector2(2,-2)

	log_entry_panel.add_child(log_entry_label)
	$LogContainer.add_child(log_entry_panel)

	displayed_logs.append(log_entry_text)  # Track this log
	
	# Fade out the log entry after a delay
	fade_out_log(log_entry_panel)

func fade_out_log(log_entry_panel: Panel):
	var tween = get_tree().create_tween()
	tween.tween_property(log_entry_panel, "modulate:a", 0.0, FADE_DURATION)
	logs_to_fade.append(tween)
	# Remove the label once the fade is complete
	await tween.finished
	emit_signal("fade_complete", tween, log_entry_panel)

func _on_fade_complete(tween, log_entry_panel):
	logs_to_fade.erase(tween)
	if is_instance_valid(log_entry_panel):
		displayed_logs.erase(log_entry_panel)  # Remove from tracker
		$LogContainer.remove_child(log_entry_panel)
		log_entry_panel.queue_free()  # Free memory

func _on_logger_new_log(log_entry: Dictionary) -> void:
	if log_entry not in Logger.logs:
		Logger.logs.append(log_entry)
	if log_entry not in displayed_logs:
		add_log_entry(log_entry)

func _on_update_timer_timeout():
	refresh_logs()
