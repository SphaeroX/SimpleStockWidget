package de.sphaerox.simple_stock_widget.widget

import android.content.Context
import android.net.Uri
import androidx.work.WorkManager
import es.antonborri.home_widget.HomeWidgetBackgroundIntent
import es.antonborri.home_widget.HomeWidgetGlanceWidgetReceiver

class StockWidgetReceiver : HomeWidgetGlanceWidgetReceiver<StockGlanceWidget>() {
  override val glanceAppWidget = StockGlanceWidget()

  /** Erstes Widget hinzugefügt → Dart plant das Auto-Update (lib/widget_sync/background.dart). */
  override fun onEnabled(context: Context) {
    super.onEnabled(context)
    try {
      HomeWidgetBackgroundIntent.getBroadcast(context, Uri.parse(WidgetKeys.SCHEDULE_URI)).send()
    } catch (_: Exception) {}
  }

  /** Letztes Widget entfernt → periodischen Job stoppen. */
  override fun onDisabled(context: Context) {
    super.onDisabled(context)
    WorkManager.getInstance(context).cancelUniqueWork(WidgetKeys.PERIODIC_WORK)
  }
}
