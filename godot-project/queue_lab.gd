
extends Control

const BG := Color("#101b2b")
const PANEL := Color("#172538")
const BLUE := Color("#60a5fa")
const YELLOW := Color("#fbbf24")
const GREEN := Color("#34d399")
const RED := Color("#f87171")
const PURPLE := Color("#a78bfa")

const ARRIVAL_MIN := 0.65
const ARRIVAL_MAX := 1.35
const SERVICE_TIME := 3.2
const MAX_AGENTS := 120

var agents: Array[Dictionary] = []
var next_id := 1
var elapsed := 0.0
var arrival_timer := 0.0
var service_timer := 0.0
var active_id := -1

var served := 0
var abandoned := 0
var created := 0

var running := true
var patience_enabled := false

var stats_label: Label
var info_label: Label
var rule_button: Button
var pause_button: Button

var rng := RandomNumberGenerator.new()


func _ready() -> void:
	rng.randomize()
	set_anchors_and_offsets_preset(
		Control.PRESET_FULL_RECT
	)
	_build_ui()
	restart()


func _build_ui() -> void:
	var top := PanelContainer.new()
	top.set_anchors_preset(Control.PRESET_TOP_WIDE)
	top.offset_bottom = 104
	add_child(top)

	var bar := VBoxContainer.new()
	bar.add_theme_constant_override("separation", 8)
	top.add_child(bar)

	var title := Label.new()
	title.text = "QUEUE LAB  /  THE QUEUE THAT LOSES PATIENCE"
	title.add_theme_font_size_override("font_size", 20)
	bar.add_child(title)

	var controls := HBoxContainer.new()
	bar.add_child(controls)

	rule_button = Button.new()
	rule_button.text = "Cierpliwosc: OFF"
	rule_button.pressed.connect(toggle_patience)
	controls.add_child(rule_button)

	pause_button = Button.new()
	pause_button.text = "Pauza"
	pause_button.pressed.connect(toggle_pause)
	controls.add_child(pause_button)

	var reset_button := Button.new()
	reset_button.text = "Restart"
	reset_button.pressed.connect(restart)
	controls.add_child(reset_button)

	var bottom := PanelContainer.new()
	bottom.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	bottom.offset_top = -100
	add_child(bottom)

	var stack := VBoxContainer.new()
	bottom.add_child(stack)

	stats_label = Label.new()
	stats_label.add_theme_font_size_override(
		"font_size", 18
	)
	stack.add_child(stats_label)

	info_label = Label.new()
	info_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	stack.add_child(info_label)

	queue_redraw()


func restart() -> void:
	agents.clear()
	next_id = 1
	elapsed = 0.0
	arrival_timer = 0.15
	service_timer = 0.0
	active_id = -1
	served = 0
	abandoned = 0
	created = 0
	running = true
	patience_enabled = false

	if is_instance_valid(rule_button):
		rule_button.text = "Cierpliwosc: OFF"
	if is_instance_valid(pause_button):
		pause_button.text = "Pauza"

	_update_labels()
	queue_redraw()


func toggle_patience() -> void:
	patience_enabled = not patience_enabled

	if patience_enabled:
		rule_button.text = "Cierpliwosc: ON"
	else:
		rule_button.text = "Cierpliwosc: OFF"

	_update_labels()
	queue_redraw()


func toggle_pause() -> void:
	running = not running
	pause_button.text = "Pauza" if running else "Wznow"
	_update_labels()


func _process(delta: float) -> void:
	if not running:
		return

	elapsed += delta
	arrival_timer -= delta

	if arrival_timer <= 0.0 and created < MAX_AGENTS:
		_spawn_agent()
		arrival_timer = rng.randf_range(
			ARRIVAL_MIN, ARRIVAL_MAX
		)

	_update_patience(delta)
	_update_service(delta)
	_update_movement(delta)
	_update_labels()
	queue_redraw()


func _spawn_agent() -> void:
	var agent := {
		"id": next_id,
		"state": "WAITING",
		"wait": 0.0,
		"limit": rng.randf_range(7.0, 17.0),
		"pos": Vector2(-35, 0),
		"exit_time": 0.0
	}

	agents.append(agent)
	next_id += 1
	created += 1


func _update_patience(delta: float) -> void:
	for i in range(agents.size()):
		var a: Dictionary = agents[i]

		if a["state"] != "WAITING":
			continue

		a["wait"] += delta

		if patience_enabled and a["wait"] >= a["limit"]:
			a["state"] = "LEAVING"
			a["exit_time"] = 0.0
			abandoned += 1

		agents[i] = a


func _update_service(delta: float) -> void:
	if active_id != -1:
		service_timer -= delta

		if service_timer <= 0.0:
			for i in range(agents.size()):
				var a: Dictionary = agents[i]

				if a["id"] == active_id:
					a["state"] = "DONE"
					a["exit_time"] = 0.0
					agents[i] = a
					served += 1
					break

			active_id = -1

	if active_id == -1:
		for i in range(agents.size()):
			var a: Dictionary = agents[i]

			if a["state"] == "WAITING":
				a["state"] = "SERVING"
				agents[i] = a
				active_id = a["id"]
				service_timer = SERVICE_TIME
				break


func _update_movement(delta: float) -> void:
	var waiting_index := 0
	var width_available := maxf(size.x - 250.0, 200.0)
	var slot_gap := 43.0
	var capacity := maxi(
		1, int(width_available / slot_gap)
	)

	for i in range(agents.size()):
		var a: Dictionary = agents[i]
		var target := Vector2.ZERO
		var state: String = a["state"]

		match state:
			"WAITING":
				var col := waiting_index % capacity
				var row_index := int(
					waiting_index / capacity
				)

				target = Vector2(
					size.x - 200.0 - col * slot_gap,
					size.y * 0.46 + row_index * 49.0
				)
				waiting_index += 1

			"SERVING":
				target = Vector2(
					size.x - 75.0,
					size.y * 0.46
				)

			"DONE":
				target = Vector2(
					size.x + 60.0,
					size.y * 0.30
				)
				a["exit_time"] += delta

			"LEAVING":
				target = Vector2(
					size.x * 0.45,
					size.y + 60.0
				)
				a["exit_time"] += delta

		a["pos"] = a["pos"].lerp(
			target,
			minf(1.0, delta * 4.0)
		)
		agents[i] = a

	for i in range(agents.size() - 1, -1, -1):
		var a: Dictionary = agents[i]
		if a["state"] in ["DONE", "LEAVING"]:
			if a["exit_time"] > 2.0:
				agents.remove_at(i)


func _update_labels() -> void:
	if not is_instance_valid(stats_label):
		return

	var waiting := 0

	for a in agents:
		if a["state"] == "WAITING":
			waiting += 1

	stats_label.text = (
		"Obsluzeni: %d    Rezygnacje: %d    "
		+ "W kolejce: %d    Utworzeni: %d"
	) % [served, abandoned, waiting, created]

	var mode := "AKTYWNY" if patience_enabled else "WYLACZONY"
	var status := "DZIALA" if running else "PAUZA"

	info_label.text = (
		"Czas: %.1f s  |  FIFO  |  "
		+ "Limit cierpliwosci: %s  |  %s"
	) % [elapsed, mode, status]


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), BG)

	var y := size.y * 0.46

	draw_rect(
		Rect2(15, y - 75, size.x - 30, 175),
		PANEL
	)

	draw_line(
		Vector2(25, y),
		Vector2(size.x - 30, y),
		Color("#425773"), 2.0
	)

	draw_rect(
		Rect2(size.x - 125, y - 40, 100, 80),
		Color("#234c50")
	)

	_draw_text(
		Vector2(size.x - 120, y - 51),
		"STANOWISKO", 13, GREEN
	)

	_draw_text(
		Vector2(20, y - 90),
		"WEJSCIE", 14, BLUE
	)

	for a in agents:
		var p: Vector2 = a["pos"]
		var state: String = a["state"]
		var c := BLUE
		var label_text := "CZEKA"

		match state:
			"WAITING":
				if patience_enabled:
					var remaining: float = (
						a["limit"] - a["wait"]
					)
					if remaining < 4.0:
						c = YELLOW
						label_text = "PILNE"

			"SERVING":
				c = GREEN
				label_text = "OBSL."

			"DONE":
				c = PURPLE
				label_text = "GOTOWE"

			"LEAVING":
				c = RED
				label_text = "REZ."

		draw_circle(p, 16.0, c)
		_draw_text(
			p + Vector2(-10, 5),
			str(a["id"]), 12, BG
		)
		_draw_text(
			p + Vector2(-19, 31),
			label_text, 10, c
		)


func _draw_text(
	pos: Vector2,
	value: String,
	font_size: int,
	color: Color
) -> void:
	draw_string(
		ThemeDB.fallback_font,
		pos,
		value,
		HORIZONTAL_ALIGNMENT_LEFT,
		-1,
		font_size,
		color
	)
