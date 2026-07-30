extends Node

## Power-up stock is a persistent economy (see PowerUps.md#economy), not a per-level
## grant: it survives across levels, refills over real time, and is refunded if an
## attempt doesn't end in a completion. `LevelData.power_up_unlocks` just marks which
## power-up types are unlocked (visible/usable) from this level onward, matching the
## scripted tutorial introductions in Levels 2-4 — it doesn't grant any charges.

signal charges_changed(power_up_id: String, remaining: int)

const MAX_STOCK: int = 3
const REFILL_INTERVAL_SECONDS: float = 600.0

var armed_power_up: String = ""
var map_fragment_snapshot: Dictionary = {}
var map_unlocked: bool = false
var move_limit: int = -1
var moves_remaining: int = -1

var _charges: Dictionary = {}
var _unlocked: Dictionary = {}            # power_up_id -> true
var _last_refill_time: Dictionary = {}    # power_up_id -> unix seconds; only present while stock < MAX_STOCK
var _spent_this_attempt: Dictionary = {}  # power_up_id -> charges spent since the current attempt started
var _visited_rooms: Dictionary = {}       # room_id -> true
var _known_connections: Dictionary = {}   # from_room_id -> Array[{"to": String, "label": String}]

func start_level(level: LevelData) -> void:
	armed_power_up = ""
	_visited_rooms.clear()
	_known_connections.clear()
	map_fragment_snapshot = {}
	map_unlocked = level.starts_with_map_unlocked
	move_limit = level.move_limit
	moves_remaining = level.move_limit
	for power_up_id in level.power_up_unlocks:
		unlock_power_up(power_up_id)

## Call once an attempt is over. `completed` refunds nothing (the spend was real);
## a failed/abandoned attempt gets every charge spent during it back in stock.
func end_attempt(completed: bool) -> void:
	if not completed:
		for power_up_id in _spent_this_attempt:
			var spent: int = _spent_this_attempt[power_up_id]
			if spent <= 0:
				continue
			var refunded: int = mini(MAX_STOCK, _charges.get(power_up_id, MAX_STOCK) + spent)
			_charges[power_up_id] = refunded
			if refunded >= MAX_STOCK:
				_last_refill_time.erase(power_up_id)
			charges_changed.emit(power_up_id, refunded)
	_spent_this_attempt.clear()

func has_unlimited_moves() -> bool:
	return move_limit < 0

func consume_move() -> void:
	if has_unlimited_moves():
		return
	moves_remaining = maxi(moves_remaining - 1, 0)

func is_out_of_moves() -> bool:
	return not has_unlimited_moves() and moves_remaining <= 0

func get_moves_used() -> int:
	if has_unlimited_moves():
		return 0
	return move_limit - moves_remaining

func unlock_power_up(power_up_id: String) -> void:
	if _unlocked.get(power_up_id, false):
		return
	_unlocked[power_up_id] = true
	charges_changed.emit(power_up_id, get_charges(power_up_id))

func is_unlocked(power_up_id: String) -> bool:
	return _unlocked.get(power_up_id, false)

func get_charges(power_up_id: String) -> int:
	if not _unlocked.get(power_up_id, false):
		return 0
	_apply_refill(power_up_id)
	return _charges.get(power_up_id, MAX_STOCK)

## Seconds left until this power-up's next charge — 0 if it's already at MAX_STOCK
## (or not unlocked), since there's nothing accruing in either case.
func get_seconds_until_next_charge(power_up_id: String) -> int:
	if not _unlocked.get(power_up_id, false):
		return 0
	_apply_refill(power_up_id)
	if _charges.get(power_up_id, MAX_STOCK) >= MAX_STOCK or not _last_refill_time.has(power_up_id):
		return 0
	var elapsed: float = Time.get_unix_time_from_system() - _last_refill_time[power_up_id]
	return int(ceil(REFILL_INTERVAL_SECONDS - elapsed))

func arm(power_up_id: String) -> bool:
	if get_charges(power_up_id) <= 0:
		return false
	armed_power_up = power_up_id
	return true

func disarm() -> void:
	armed_power_up = ""

## The tutorial band (Levels 1-4, unlimited moves) demonstrates each power-up once but
## never spends from the real stock — real spending starts at Level 5, so a fresh
## player always reaches it with the full 3 of each, never fewer.
func consume(power_up_id: String) -> void:
	if has_unlimited_moves():
		armed_power_up = ""
		return
	var current: int = get_charges(power_up_id)
	if current > 0:
		if current == MAX_STOCK:
			_last_refill_time[power_up_id] = Time.get_unix_time_from_system()
		var new_charges: int = current - 1
		_charges[power_up_id] = new_charges
		_spent_this_attempt[power_up_id] = _spent_this_attempt.get(power_up_id, 0) + 1
		charges_changed.emit(power_up_id, new_charges)
	armed_power_up = ""

## Lazily catches stock up to where real-time refill should have brought it,
## carrying over any leftover fractional interval instead of resetting it away.
func _apply_refill(power_up_id: String) -> void:
	var current: int = _charges.get(power_up_id, MAX_STOCK)
	if current >= MAX_STOCK or not _last_refill_time.has(power_up_id):
		return
	var elapsed: float = Time.get_unix_time_from_system() - _last_refill_time[power_up_id]
	var earned: int = int(elapsed / REFILL_INTERVAL_SECONDS)
	if earned <= 0:
		return
	var new_charges: int = mini(MAX_STOCK, current + earned)
	_charges[power_up_id] = new_charges
	if new_charges >= MAX_STOCK:
		_last_refill_time.erase(power_up_id)
	else:
		_last_refill_time[power_up_id] += float(earned) * REFILL_INTERVAL_SECONDS
	charges_changed.emit(power_up_id, new_charges)

func mark_visited(room_id: String) -> void:
	_visited_rooms[room_id] = true

func get_visited_rooms() -> Array:
	return _visited_rooms.keys()

func record_known_connection(from_room_id: String, destination_room_id: String, portal_label: String, portal_color: Color) -> void:
	if not _known_connections.has(from_room_id):
		_known_connections[from_room_id] = []
	for entry in _known_connections[from_room_id]:
		if entry["to"] == destination_room_id:
			return
	_known_connections[from_room_id].append({"to": destination_room_id, "label": portal_label, "color": portal_color})

func has_known_connections() -> bool:
	return not _known_connections.is_empty()

func snapshot_known_connections() -> void:
	map_fragment_snapshot = _known_connections.duplicate(true)

func has_map_fragment_snapshot() -> bool:
	return not map_fragment_snapshot.is_empty()

func unlock_map() -> void:
	map_unlocked = true
