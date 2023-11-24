module mvconvert

fn test_camel_to_snake(){
	input := "CamelCase"
	actual := camel_to_snake(input)
	assert(actual == "camel_case")
}