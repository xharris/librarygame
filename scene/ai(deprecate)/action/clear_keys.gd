extends BTAction

@export var keys:Array[String]

func tick(actor, data:Dictionary) -> STATUS:
	for key in keys:
		if data.has(key):
			data.erase(key)
	return success('Erased %s'%[','.join(keys)])
