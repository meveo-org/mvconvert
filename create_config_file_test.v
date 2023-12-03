module mvconvert

import os

fn test_create_config_files() {
    println('Running test: test_create_config_files')
    // Setup test data
	output_dir := './out/'
    if !os.exists(output_dir + '/setConfig.sh') {
        create_config_files(output_dir) or {
            assert false, 'Function failed: $err'
        }
        //check a README.md file has been created in output_dir
        assert os.exists(output_dir + '/README.md'), 'README.md file not created'

        //check a setConfig.sh file has been created in output_dir
        assert os.exists(output_dir + '/setConfig.sh'), 'setConfig.sh file not created'
    }
}