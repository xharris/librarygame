@icon('../icon/x-circle.svg')
class_name BTFailer
extends BTDecorator

func transform(response:STATUS, data:Dictionary):
	return STATUS.FAILURE
