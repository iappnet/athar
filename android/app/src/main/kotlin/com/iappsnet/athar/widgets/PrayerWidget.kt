package com.iappsnet.athar.widgets

import android.content.Context
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.glance.GlanceId
import androidx.glance.GlanceModifier
import androidx.glance.GlanceTheme
import androidx.glance.appwidget.GlanceAppWidget
import androidx.glance.appwidget.provideContent
import androidx.glance.background
import androidx.glance.layout.*
import androidx.glance.text.FontWeight
import androidx.glance.text.Text
import androidx.glance.text.TextStyle
import java.time.Instant
import java.time.ZoneId
import java.time.format.DateTimeFormatter

class PrayerWidget : GlanceAppWidget() {

    override suspend fun provideGlance(context: Context, id: GlanceId) {
        val prefs = context.getSharedPreferences("HomeWidgetPreferences", Context.MODE_PRIVATE)
        val nameAr = prefs.getString("athar_next_prayer_name_ar", "الفجر") ?: "الفجر"
        val nameEn = prefs.getString("athar_next_prayer_name_en", "Fajr") ?: "Fajr"
        val timeIso = prefs.getString("athar_next_prayer_time", null)
        val city = prefs.getString("athar_city_name", "الرياض") ?: "الرياض"

        val timeDisplay = timeIso?.let {
            try {
                val instant = Instant.parse(it)
                val local = instant.atZone(ZoneId.systemDefault())
                DateTimeFormatter.ofPattern("h:mm a").format(local)
            } catch (_: Exception) { "" }
        } ?: ""

        provideContent {
            PrayerWidgetContent(nameAr = nameAr, nameEn = nameEn, time = timeDisplay, city = city)
        }
    }
}

@Composable
private fun PrayerWidgetContent(nameAr: String, nameEn: String, time: String, city: String) {
    Box(
        modifier = GlanceModifier
            .fillMaxSize()
            .background(Color(0xCC1A1A2E)),
        contentAlignment = Alignment.Center,
    ) {
        Column(
            modifier = GlanceModifier.padding(horizontal = 12.dp, vertical = 8.dp),
            horizontalAlignment = Alignment.CenterHorizontally,
        ) {
            Text(
                text = nameAr,
                style = TextStyle(
                    color = androidx.glance.unit.ColorProvider(Color.White),
                    fontSize = 16.sp,
                    fontWeight = FontWeight.Bold,
                ),
            )
            Spacer(modifier = GlanceModifier.height(4.dp))
            Text(
                text = time,
                style = TextStyle(
                    color = androidx.glance.unit.ColorProvider(Color(0xFFD4AF37)),
                    fontSize = 20.sp,
                    fontWeight = FontWeight.Bold,
                ),
            )
            Spacer(modifier = GlanceModifier.height(2.dp))
            Text(
                text = city,
                style = TextStyle(
                    color = androidx.glance.unit.ColorProvider(Color(0xAAFFFFFF)),
                    fontSize = 11.sp,
                ),
            )
        }
    }
}
