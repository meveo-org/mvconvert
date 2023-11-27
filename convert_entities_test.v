module mvconvert

import os

fn test_convert_entities() {
    println('Running test: test_convert_entities')
    // Setup test data
    cet_dir := './meveoModuleExample/mv-todolist/customEntityTemplate'
	cft_dir := './meveoModuleExample/mv-todolist/customFieldTemplate'
    output_test_dir := './output'
	todo_test_dir := './output/mvtodolist'
    os.mkdir_all(todo_test_dir) or { assert false, 'Failed to create test output directory' }
    println('Created test output directory: $todo_test_dir')
    //defer { os.rmdir_all(output_test_dir) or { } } // Clean up after test

    // Call the function with test data
    result := convert_entities(cet_dir, cft_dir, todo_test_dir,"mvtodolist") or {
        assert false, 'Function failed: $err'
		[]FileError{}
    }
    eprintln('convert_entities result: $result')
    // Assert expectations
    assert result.len == 0 // Assuming a successful run returns an empty array

    // Check the output files and other side effects
    // ...
}