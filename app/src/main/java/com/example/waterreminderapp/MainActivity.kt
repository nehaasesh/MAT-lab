package com.example.waterreminderapp

import android.os.Bundle
import android.widget.Button
import android.widget.TextView
import androidx.appcompat.app.AppCompatActivity

class MainActivity : AppCompatActivity() {

    var count = 0

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        val countText = findViewById<TextView>(R.id.countText)
        val drinkButton = findViewById<Button>(R.id.drinkButton)

        drinkButton.setOnClickListener {
            count++
            countText.text = "Water Count: $count"
        }
    }
}