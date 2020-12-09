package com.kanade.f_todo.entity

open class BaseEntity {
    open var title: String = ""
    open var content: String = ""
    open var createdTime: Long = -1
    open var completedTime: Long = -1
}