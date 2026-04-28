package com.iappsnet.athar.widgets

import android.content.Context
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.glance.GlanceId
import androidx.glance.GlanceModifier
import androidx.glance.appwidget.GlanceAppWidget
import androidx.glance.appwidget.lazy.LazyColumn
import androidx.glance.appwidget.lazy.items
import androidx.glance.appwidget.provideContent
import androidx.glance.background
import androidx.glance.layout.*
import androidx.glance.text.FontWeight
import androidx.glance.text.Text
import androidx.glance.text.TextStyle
import androidx.glance.unit.ColorProvider
import org.json.JSONArray

data class WidgetHabit(val title: String, val done: Boolean, val streak: Int)

class HabitWidget : GlanceAppWidget() {

    override suspend fun provideGlance(context: Context, id: GlanceId) {
        val prefs = context.getSharedPreferences("HomeWidgetPreferences", Context.MODE_PRIVATE)
        val habitsJson = prefs.getString("athar_habits", "[]") ?: "[]"
        val total = prefs.getInt("athar_habits_total", 0)
        val done  = prefs.getInt("athar_habits_done", 0)

        val habits = parseHabitsJson(habitsJson)

        provideContent {
            HabitWidgetContent(habits = habits, total = total, done = done)
        }
    }

    private fun parseHabitsJson(json: String): List<WidgetHabit> {
        return try {
            val arr = JSONArray(json)
            (0 until arr.length()).map { i ->
                val obj = arr.getJSONObject(i)
                WidgetHabit(
                    title  = obj.optString("t", ""),
                    done   = obj.optBoolean("d", false),
                    streak = obj.optInt("s", 0),
                )
            }
        } catch (_: Exception) {
            emptyList()
        }
    }
}

@Composable
private fun HabitWidgetContent(habits: List<WidgetHabit>, total: Int, done: Int) {
    Column(
        modifier = GlanceModifier
            .fillMaxSize()
            .background(Color(0xCC1A1A2E))
            .padding(12.dp),
    ) {
        // Header
        Row(
            modifier = GlanceModifier.fillMaxWidth(),
            verticalAlignment = Alignment.CenterVertically,
        ) {
            Text(
                text = "العادات",
                style = TextStyle(
                    color = ColorProvider(Color.White),
                    fontSize = 13.sp,
                    fontWeight = FontWeight.Bold,
                ),
                modifier = GlanceModifier.defaultWeight(),
            )
            Text(
                text = "$done/$total",
                style = TextStyle(
                    color = ColorProvider(Color(0xFFD4AF37)),
                    fontSize = 12.sp,
                ),
            )
        }

        Spacer(modifier = GlanceModifier.height(6.dp))

        if (habits.isEmpty()) {
            Box(
                modifier = GlanceModifier.fillMaxSize(),
                contentAlignment = Alignment.Center,
            ) {
                Text(
                    text = "لا توجد عادات",
                    style = TextStyle(
                        color = ColorProvider(Color(0xAAFFFFFF)),
                        fontSize = 12.sp,
                    ),
                )
            }
        } else {
            LazyColumn(modifier = GlanceModifier.fillMaxSize()) {
                items(habits) { habit ->
                    HabitRow(habit = habit)
                }
            }
        }
    }
}

@Composable
private fun HabitRow(habit: WidgetHabit) {
    Row(
        modifier = GlanceModifier
            .fillMaxWidth()
            .padding(vertical = 3.dp),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        Text(
            text = if (habit.done) "✓" else "○",
            style = TextStyle(
                color = ColorProvider(
                    if (habit.done) Color(0xFF4CAF50) else Color(0xAAFFFFFF),
                ),
                fontSize = 11.sp,
            ),
        )
        Spacer(modifier = GlanceModifier.width(6.dp))
        Text(
            text = habit.title,
            style = TextStyle(
                color = ColorProvider(
                    if (habit.done) Color(0x88FFFFFF) else Color.White,
                ),
                fontSize = 12.sp,
            ),
            modifier = GlanceModifier.defaultWeight(),
        )
        if (habit.streak > 0) {
            Text(
                text = "🔥${habit.streak}",
                style = TextStyle(
                    color = ColorProvider(Color(0xFFFF8C00)),
                    fontSize = 10.sp,
                ),
            )
        }
    }
}
