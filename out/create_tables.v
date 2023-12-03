
import os
import db.pg
import mvtodolist

fn main() {
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

    sql db { create table mvtodolist.TodoList} or {eprintln(err)}
    sql db { create table mvtodolist.TodoItem} or {eprintln(err)}
}
