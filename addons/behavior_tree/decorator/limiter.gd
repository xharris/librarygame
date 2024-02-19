class_name BTLimiter
extends BTDecorator

@export var limit:int = 1

var _called = 0

func transform(response:STATUS):
	_called += 1
	if _called >= limit:
		return STATUS.FAILURE
	return response
