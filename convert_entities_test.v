module mvconvert

import os

fn test_convert_entities() {
    println('Running test: test_convert_entities')
    // Setup test data
    cet_dir := os.join_path('meveoModuleExample','mv-todolist','customEntityTemplates')
	cft_dir := os.join_path('meveoModuleExample','mv-todolist','customFieldTemplates')
    output_test_dir := 'out'
	todo_test_dir := os.join_path('out','mvtodolist')
    os.mkdir_all(todo_test_dir) or { assert false, 'Failed to create test output directory' }
    println('Created test output directory: $todo_test_dir')
    //defer { os.rmdir_all(output_test_dir) or { } } // Clean up after test

    // Call the function with test data
    result,entities := convert_entities(cet_dir, cft_dir, todo_test_dir,"mvtodolist") or {
        assert false, 'Function failed: $err'
		[]FileError{},[]CustomEntity{}
    }
    eprintln('convert_entities result: $result')
    // Assert expectations
    assert result.len == 0 // Assuming a successful run returns an empty array
    assert entities.len == 2 // Assuming a successful run returns 2 entities
    
    create_db_file(entities,output_test_dir,"mvtodolist") or {
        assert false, 'Function failed: $err'
    }
    //check a create_tables.v file has been created in todo_test_dir
    assert os.exists(os.join_path(output_test_dir,'create_tables.v')), 'create_tables.v file not created'
}