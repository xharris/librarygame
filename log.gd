extends Node

enum LEVEL {DEBUG,INFO,WARN,ERROR}
var global_level:LEVEL = LEVEL.INFO

func new(_level:LEVEL = LEVEL.INFO) -> Logger:
	return Logger.new(_level)

class Logger:
	var log_name:String = '_'
	var level:LEVEL = LEVEL.INFO
	var stack_offset:int = 0

	func _init(_level:LEVEL = LEVEL.INFO):
		level = _level

	func _log(_level:LEVEL, icon:String, message:Variant, args:Array = []) -> bool:
		if Log.global_level <= _level or level <= _level:
			var stack = get_stack().pop_at(2+stack_offset)
			var content = str(message)
			if args.size():
				content = message % args
			print('['+icon+'] '+content+' \t\t('+stack.get('source')+':'+str(stack.get('line'))+')')
			return true
		return false

	func debug(message:Variant, args:Array = []):
		_log(LEVEL.DEBUG, 'x', message, args)
		
	func info(message:Variant, args:Array = []):
		_log(LEVEL.INFO, 'i', message, args)
		
	func warn(message:Variant, args:Array = []):
		if _log(LEVEL.WARN, '?', message, args):
			push_warning(message % args)
		
	func error(message:Variant, args:Array = []):
		if _log(LEVEL.ERROR, '!', message, args):
			push_error(message % args)
