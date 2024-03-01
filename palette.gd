extends Node

var Red500 = Color.html('#F44336')

var Blue500 = Color.html('#2196F3')

var LightBlue100 = Color.html('#E1F5FE')
var LightBlue200 = Color.html('#B3E5FC')

var Green500 = Color.html('#4CAF50')

var BlueGrey900 = Color.html('#263238')

func pick_random() -> Color:
	var colors:Array[Color] = []
	var prop_list = get_property_list()
	for prop in prop_list:
		if prop.get('name') in self and typeof(self[prop.get('name')]) == TYPE_COLOR:
			colors.append(self[prop.get('name')])
	return colors.pick_random()

func lerp_colors(colors:Array[Color], offset:float) -> Color:
# If there's only one color, just return it
	if colors.size() == 1:
		return colors[0]
	
	# Calculate which two colors we need to interpolate between
	var pos := wrapf(offset, 0, 1) * (colors.size() - 1)
	var index := wrapi(int(pos), 0, colors.size()-1) # This will give the first color's index
	var next_index := wrapi(index + 1, 0, colors.size()-1)
	var weight := pos - index # This will give the weight for the lerp
	
	# Interpolate between the two colors using the lerp function
	var color1 := colors[index]
	var color2 := colors[next_index] # Ensure we don't go out of bounds
	return color1.lerp(color2, weight)
