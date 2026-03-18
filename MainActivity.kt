package com.example.techloungeapp

import android.os.Bundle
import android.widget.Button
import android.widget.TextView
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity

class MainActivity : AppCompatActivity() {

    private var count = 0

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        val countText = findViewById<TextView>(R.id.countText)
        val checkInBtn = findViewById<Button>(R.id.checkInBtn)
        val checkOutBtn = findViewById<Button>(R.id.checkOutBtn)

        checkInBtn.setOnClickListener {
            count++
            countText.text = count.toString()
        }

        checkOutBtn.setOnClickListener {
            if (count > 0) {
                count--
                countText.text = count.toString()
            } else {
                Toast.makeText(this, "No students inside!", Toast.LENGTH_SHORT).show()
            }
        }
    }
}
