module mvtodolist

@[table: 'todoitem']
struct TodoItem {
    uuid string [primary]
    status ?string 
    todolist ?TodoList 
    value ?string 
}
