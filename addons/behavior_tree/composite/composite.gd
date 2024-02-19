class_name BTComposite
extends BTNode

var _last_node:BTNode
var _last_status:STATUS
var l = Log.new()#Log.LEVEL.DEBUG)

func _ready():
	l.stack_offset = 1

func log_node_status(node:BTNode, status:STATUS):
	if _last_node == node and _last_status == status:
		return false
	_last_node = node
	_last_status = status
	l.debug('%s %s', [node, STATUS.find_key(status)])
	return true
