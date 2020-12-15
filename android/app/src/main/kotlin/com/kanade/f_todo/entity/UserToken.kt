package com.kanade.f_todo.entity

data class UserToken(
        val account:String,
        val expiresIn:Long,
        val loginTime:Long,
        val accessToken:String,
)