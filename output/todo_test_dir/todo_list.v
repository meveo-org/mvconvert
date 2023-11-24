module mvtodolist

@[table: 'todolist']
struct TodoList {
        uuid string
    active ?bool 
    name string 
    todoItems ?string 
}
