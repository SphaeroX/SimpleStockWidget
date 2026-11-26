package de.sphaerox.simple_stock_widget.widget

import android.content.Context
import android.net.Uri
import androidx.glance.GlanceId
import androidx.glance.action.ActionParameters
import androidx.glance.appwidget.action.ActionCallback
import es.antonborri.home_widget.HomeWidgetBackgroundIntent

/** Reload-Button: startet den Dart-Hintergrund-Callback (siehe lib/widget_sync/background.dart). */
class ReloadAction : ActionCallback {
  override suspend fun onAction(context: Context, glanceId: GlanceId, parameters: ActionParameters) {
    HomeWidgetBackgroundIntent.getBroadcast(context, Uri.parse(WidgetKeys.RELOAD_URI)).send()
  }
}
