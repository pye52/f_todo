package com.kanade.f_todo.entity

data class MscCalendar(
        var id: String,
        override var title: String,
        override var content: String,
        override var createdTime: Long,
        override var completedTime: Long,
) : BaseEntity() 