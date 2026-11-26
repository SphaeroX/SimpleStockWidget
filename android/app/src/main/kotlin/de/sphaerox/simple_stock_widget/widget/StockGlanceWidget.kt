package de.sphaerox.simple_stock_widget.widget

import android.content.Context
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.glance.GlanceId
import androidx.glance.GlanceModifier
import androidx.glance.action.clickable
import androidx.glance.appwidget.GlanceAppWidget
import androidx.glance.appwidget.provideContent
import androidx.glance.background
import androidx.glance.currentState
import androidx.glance.layout.Column
import androidx.glance.layout.Row
import androidx.glance.layout.fillMaxSize
import androidx.glance.layout.padding
import androidx.glance.text.Text
import androidx.glance.text.TextStyle
import androidx.glance.unit.ColorProvider
import de.sphaerox.simple_stock_widget.MainActivity
import es.antonborri.home_widget.HomeWidgetGlanceState
import es.antonborri.home_widget.HomeWidgetGlanceStateDefinition
import es.antonborri.home_widget.actionStartActivity

class StockGlanceWidget : GlanceAppWidget() {
  override val stateDefinition = HomeWidgetGlanceStateDefinition()

  override suspend fun provideGlance(context: Context, id: GlanceId) {
    provideContent { Content(context, currentState()) }
  }

  @Composable
  private fun Content(context: Context, state: HomeWidgetGlanceState) {
    val payload = WidgetPayload.parse(state.preferences.getString(WidgetKeys.PAYLOAD, null))
    val white = ColorProvider(Color.White)
    Column(
        modifier = GlanceModifier.fillMaxSize().background(Color(0xE61E1E1E)).padding(12.dp)
            .clickable(actionStartActivity<MainActivity>(context))
    ) {
      Text("Letzter Abruf: ${payload?.updatedLabel ?: "–"}", style = TextStyle(color = ColorProvider(Color.Gray), fontSize = 12.sp))
      payload?.rows?.forEach { r ->
        val c = when (r.dir) { "up" -> Color(0xFFB5E36B); "down" -> Color(0xFFF26D6D); else -> Color.LightGray }
        Row {
          Text(r.name, style = TextStyle(color = white, fontSize = 14.sp))
          Text("  ${r.price}  ", style = TextStyle(color = white, fontSize = 14.sp))
          Text(r.change, style = TextStyle(color = ColorProvider(c), fontSize = 14.sp))
        }
      }
    }
  }
}
