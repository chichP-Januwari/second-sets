extends TileMapLayer

# Nodes
@onready var key = $Key
@onready var exit_door = $ExitDoor
@onready var vault = $Vault

# Signal
signal interacted(interactable: String)

var spawn_point

func _ready() -> void:
	exit_door.body_entered.connect(_exit_entered)
	key.body_entered.connect(_key_entered)
	vault.body_entered.connect(_vault_entered)
	spawn_point = exit_door.position

func _exit_entered(body: Node2D):
	if body == Player:
		emit_signal("interacted", ["Exit"])

func _key_entered(body: Node2D):
	if body == Player:
		emit_signal("interacted", ["Key"])

func _vault_entered(body: Node2D):
	if body == Player:
		emit_signal("interacted", ["Vault"])
