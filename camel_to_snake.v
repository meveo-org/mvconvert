module mvconvert

pub fn camel_to_snake(s string) string {
	mut result := []rune{}
	for i, c in s.runes() {
		if c.str().is_upper() && i > 0 {
            result << `_`
        }
        result << c.str().to_lower().runes()[0]
	}
	mut snake_case_string := ''
    for r in result {
        snake_case_string += r.str()
    }
    return snake_case_string
}
