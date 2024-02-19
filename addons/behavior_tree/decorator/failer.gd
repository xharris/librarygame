class_name BTFailer
extends BTDecorator

func transform(response:STATUS):
	return STATUS.FAILURE
