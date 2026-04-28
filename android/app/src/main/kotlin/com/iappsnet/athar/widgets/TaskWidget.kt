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

data class WidgetTask(val title: String, val done: Boolean, val priority: Int)

class TaskWidget : GlanceAppWidget() {

    override suspend fun provideGlance(context: Context, id: GlanceId) {
        val prefs = context.getSharedPreferences("HomeWidgetPreferences", Context.MODE_PRIVATE)
        val tasksJson = prefs.getString("athar_tasks", "[]") ?: "[]"
        val total = prefs.getInt("athar_tasks_total", 0)
        val done = prefs.getInt("athar_tasks_done", 0)

        val tasks = parseTasksJson(tasksJson)

        provideContent {
            TaskWidgetContent(tasks = tasks, total = total, done = done)
        }
    }

    private fun parseTasksJson(json: String): List<WidgetTask> {
        return try {
            val arr = JSONArray(json)
            (0 until arr.length()).map { i ->
                val obj = arr.getJSONObject(i)
                WidgetTask(
                    title = obj.optString("t", ""),
                    done = obj.optBoolean("d", false),
                    priority = obj.optInt("p", 0),
                )
            }
        } catch (_: Exception) {
            emptyList()
        }
    }
}

@Composable
private fun TaskWidgetContent(tasks: List<WidgetTask>, total: Int, done: Int) {
    Column(
        modifier = GlanceModifier
            .fillMaxSize()
            .background(Color(0xCC1A1A2E))
            .padding(12.dp),
    ) {
        Row(
            modifier = GlanceModifier.fillMaxWidth(),
            verticalAlignment = Alignment.CenterVertically,
        ) {
            Text(
                text = "مهام اليوم",
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

        if (tasks.isEmpty()) {
            Box(
                modifier = GlanceModifier.fillMaxSize(),
                contentAlignment = Alignment.Center,
            ) {
                Text(
                    text = "لا توجد مهام",
                    style = TextStyle(
                        color = ColorProvider(Color(0xAAFFFFFF)),
                        fontSize = 12.sp,
                    ),
                )
            }
        } else {
            LazyColumn(modifier = GlanceModifier.fillMaxSize()) {
                items(tasks) { task ->
                    TaskRow(task = task)
                }
            }
        }
    }
}

@Composable
private fun TaskRow(task: WidgetTask) {
    Row(
        modifier = GlanceModifier
            .fillMaxWidth()
            .padding(vertical = 3.dp),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        Text(
            text = if (task.done) "✓" else "○",
            style = TextStyle(
                color = ColorProvider(
                    if (task.done) Color(0xFF4CAF50) else Color(0xAAFFFFFF),
                ),
                fontSize = 11.sp,
            ),
        )
        Spacer(modifier = GlanceModifier.width(6.dp))
        Text(
            text = task.title,
            style = TextStyle(
                color = ColorProvider(
                    if (task.done) Color(0x88FFFFFF) else Color.White,
                ),
                fontSize = 12.sp,
            ),
            modifier = GlanceModifier.defaultWeight(),
        )
    }
}
