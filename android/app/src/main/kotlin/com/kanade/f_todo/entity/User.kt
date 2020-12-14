package com.kanade.f_todo.entity

data class User(
        val account:String,
        val expiresIn:Long,
        val loginTime:Long,
        val token:String,
)