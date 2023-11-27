module mvtodolist

import os
import db.pg
import time

fn main() ! {
    mut db_host := os.getenv('DB_HOST')
    if db_host.len == 0 {
        db_host = 'localhost' // Default value for host
    }

    mut db_port_str := os.getenv('DB_PORT')
    if db_port_str.len == 0 {
        db_port_str = '5432' // Default value for port
    }
    db_port := db_port_str.int()

    db_user := os.getenv('DB_USER')
    if db_user.len == 0 {
        eprintln('DB_USER is not set')
        return
    }

    db_password := os.getenv('DB_PASSWORD')
    if db_password.len == 0 {
        eprintln('DB_PASSWORD is not set')
        return
    }

    db_name := os.getenv('DB_NAME')
    if db_name.len == 0 {
        eprintln('DB_NAME is not set')
        return
    }

    db := pg.connect(pg.Config{
        host: db_host
        port: db_port
        user: db_user
        password: db_password
        dbname: db_name
    }) or {
        eprintln('Failed to connect to database: $err')
        return
    }


	defer {
		db.close()
	}

	sql db { create table TodoItem }!
	sql db { create table TodoList }!

	mut new_item := TodoItem{
		uuid: '21213-5454-545'
		status: 'active'
		value: 'Port meveo to Vlang.'
	}

	sql db { insert new_item into TodoItem }!

	new_list := TodoList{
		uuid: '1151-45454-554'
		active: true
		creationdate: time.now()
		name: 'My coding todo list.'
		todoitems: [new_item]
	}

	sql db { insert new_list into TodoList }!

	selected_lists := sql db {
		select from TodoList where name == 'My coding todo list.' limit 1
	}!
	my_coding_list := selected_lists.first()

	new_item = TodoItem{
		uuid: '21213-5454-545'
		status: 'inactive'
		value: 'Port meveo runtime to Vlang.'
	}
	second_item := TodoItem{
		uuid: '21213-5454-546'
		status: 'active'
		value: 'Create meveo studio web app in Vlang.'
	}

	sql db {
		update TodoList set todoitems = [new_item,second_item] where uuid == my_coding_list.uuid
	}!
}