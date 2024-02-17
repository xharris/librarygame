extends Node

var SECTION_BUFF = 'modifier-good'
var SECTION_DEBUFF = 'modifier-bad'
var SECTION_NEUTRAL = 'modifier-neutral'

var COMFORTABLE = Modifier.register('comfortable', SECTION_BUFF)

func _on_actor_use_station(actor:Actor, station:Station):
	Modifier.add_modifier(actor, COMFORTABLE)
	
func _on_actor_free_station(actor:Actor, station:Station):
	Modifier.remove_modifier(actor, COMFORTABLE)

func _ready():
	Events.actor_use_station.connect(_on_actor_use_station)
	Events.actor_free_station.connect(_on_actor_free_station)
