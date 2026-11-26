package de.sphaerox.simple_stock_widget.widget

import androidx.compose.ui.graphics.Color
import androidx.glance.color.ColorProvider

/** Farbtokens des Widgets, jeweils hell / dunkel (folgt dem System-Theme). */
object WidgetColors {
  val background = ColorProvider(day = Color(0xF2FFFFFF), night = Color(0xE61C1C1E))
  val text = ColorProvider(day = Color(0xFF1C1C1E), night = Color(0xFFFFFFFF))
  val secondary = ColorProvider(day = Color(0xFF6E6E73), night = Color(0xFF9E9EA3))
  val positive = ColorProvider(day = Color(0xFF1E8E3E), night = Color(0xFFB5E36B))
  val negative = ColorProvider(day = Color(0xFFD93025), night = Color(0xFFF26D6D))
  val neutral = ColorProvider(day = Color(0xFF6E6E73), night = Color(0xFFBDBDBD))
  val divider = ColorProvider(day = Color(0x1F000000), night = Color(0x1FFFFFFF))
}
