package de.sphaerox.simple_stock_widget.widget

import es.antonborri.home_widget.HomeWidgetGlanceWidgetReceiver

class StockWidgetReceiver : HomeWidgetGlanceWidgetReceiver<StockGlanceWidget>() {
  override val glanceAppWidget = StockGlanceWidget()
}
