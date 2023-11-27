module mvtodolist

import time

@[table: 'todolist']
struct TodoList {
    uuid string [primary]
    active ?bool 
    creationdate ?time.Time [sql_type: 'TIMESTAMP' ]
    name string 
    todoitems []TodoItem [pkey:fk_todolist ]
}
