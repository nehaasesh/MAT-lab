package com.example.fontcolorchangerapp

import android.graphics.Color
import android.graphics.Typeface
import android.os.Bundle
import android.widget.Button
import android.widget.TextView
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity

class MainActivity : AppCompatActivity() {

    private var isBold = false
    private var isRed = false

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        val sampleText = findViewById<TextView>(R.id.sampleText)
        val changeFontBtn = findViewById<Button>(R.id.changeFontBtn)
        val changeColorBtn = findViewById<Button>(R.id.changeColorBtn)

        changeFontBtn.setOnClickListener {
            if (isBold) {
                sampleText.setTypeface(null, Typeface.NORMAL)
                Toast.makeText(this, "Font changed to NORMAL", Toast.LENGTH_SHORT).show()
            } else {
                sampleText.setTypeface(null, Typeface.BOLD)
                Toast.makeText(this, "Font changed to BOLD", Toast.LENGTH_SHORT).show()
            }
            isBold = !isBold
        }

        changeColorBtn.setOnClickListener {
            if (isRed) {
                sampleText.setTextColor(Color.BLACK)
                Toast.makeText(this, "Color changed to BLACK", Toast.LENGTH_SHORT).show()
            } else {
                sampleText.setTextColor(Color.RED)
                Toast.makeText(this, "Color changed to RED", Toast.LENGTH_SHORT).show()
            }
            isRed = !isRed
        }
    }
}
