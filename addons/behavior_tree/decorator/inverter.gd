@icon('../icon/alert-circle.svg')
class_name BTInverter
extends BTDecorator

func transform(response:STATUS, data:Dictionary):
	match response:
		STATUS.SUCCESS:
			return STATUS.FAILURE
		STATUS.FAILURE:
			return STATUS.SUCCESS
		_:
			return response
