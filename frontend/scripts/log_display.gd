'''
This script manages the on-screen log display. It does this by querying the
most recent logs and then procedurely spawning them as children of the
HBoxContainer node in the log_display scene. The on-screen logs are comprised
of a panel node, a stylebox with color-coding based on log category, and
a child label node containing the log text. The logs are set to fade using
the fade_complete signal, which creates a Tween for the panel which makes
the alpha of the log fade out before being removed.
This script also uses a few arrays, logs_to_fade and displayed_logs to keep
track of the logs on screen to ensure logs do not reappear after being displayed.
'''

extends Control

signal fade_complete(tween, log_label)

const MAX_LOG_ENTRIES = 5  # Maximum number of logs to display
const FADE_DURATION = 3.0  # Duration of fade-out in seconds

var logs_to_fade = []
var displayed_logs = []

func _ready():
	refresh_logs()

func refresh_logs():
	# Called by _ready() and _on_update_timer_timeout()
	var recent_logs = Logger.logs.slice(-1, MAX_LOG_ENTRIES, -1)
	logs_to_fade.clear()
	for log_entry in recent_logs:
		if log_entry not in displayed_logs:
			add_log_entry(log_entry)

func add_log_entry(log_entry_text: Dictionary):
	# Called by refresh_logs()
	displayed_logs.append(log_entry_text)
	
	var log_entry_panel = Panel.new()
	log_entry_panel.name = "LogEntryPanel"
	# The sized of the panel/background is hard-coded because I (kinn)
	# couldn't figure out how to make it change dynamically after spawning (;-;)
	log_entry_panel.custom_minimum_size = Vector2(450, 23)
	
	var background_style = StyleBoxFlat.new()
	if log_entry_text["category"] == "Error":
		background_style.bg_color = Color(1, 0.2, 0.2, 1)  # Red for errors
	elif log_entry_text["category"] == "Warning":
		background_style.bg_color = Color(1, 1, 0.2, 0.392)  # Yellow for warnings
	else:
		background_style.bg_color = Color(0.2, 0.2, 0.2, 1)  # Default dark gray
	background_style.set_border_width_all(2)
	background_style.border_color = Color(0.5, 0.5, 0.5, 1)  # Light gray border
	log_entry_panel.add_theme_stylebox_override("panel", background_style)
	
	var log_entry_label = Label.new()
	log_entry_label.text = "[%s]: %s" % [
		log_entry_text["device"],
		log_entry_text["message"]
	]
	log_entry_label.position = Vector2(2,-2)

	log_entry_panel.add_child(log_entry_label)
	$LogContainer.add_child(log_entry_panel)

	displayed_logs.append(log_entry_text)
	
	fade_out_log(log_entry_panel)

func fade_out_log(log_entry_panel: Panel):
	# Called by add_log_entry()
	var tween = get_tree().create_tween()
	tween.tween_property(log_entry_panel, "modulate:a", 0.0, FADE_DURATION)
	logs_to_fade.append(tween)
	await tween.finished
	emit_signal("fade_complete", tween, log_entry_panel)

func _on_fade_complete(tween, log_entry_panel):
	# Called by fade_out_log()
	logs_to_fade.erase(tween)
	if is_instance_valid(log_entry_panel):
		displayed_logs.erase(log_entry_panel)
		$LogContainer.remove_child(log_entry_panel)
		log_entry_panel.queue_free()

func _on_logger_new_log(log_entry: Dictionary) -> void:
	# Called by log() in logger.gd
	if log_entry not in Logger.logs:
		Logger.logs.append(log_entry)
	if log_entry not in displayed_logs:
		add_log_entry(log_entry)

func _on_update_timer_timeout():
	refresh_logs()
