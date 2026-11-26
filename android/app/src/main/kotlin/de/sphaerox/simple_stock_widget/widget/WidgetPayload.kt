package de.sphaerox.simple_stock_widget.widget

import org.json.JSONObject

/** Spiegel von lib/widget_sync/widget_keys.dart. */
object WidgetKeys {
  const val PAYLOAD = "ssw_payload"
}

data class WidgetRow(val name: String, val price: String, val change: String, val dir: String, val currency: String = "")

data class WidgetPayload(val updatedLabel: String, val rows: List<WidgetRow>) {
  companion object {
    val preview =
        WidgetPayload(
            "22:48 Mi.",
            listOf(
                WidgetRow("NVDA", "149,30", "-3,91 %", "down"),
                WidgetRow("msci world", "72,97", "-2,28 %", "down"),
                WidgetRow("DAX", "24.702,13", "-1,26 %", "down"),
                WidgetRow("BTC-EUR", "54.896,39", "+0,60 %", "up"),
            ))

    fun parse(json: String?): WidgetPayload? {
      if (json.isNullOrBlank()) return null
      return try {
        val o = JSONObject(json)
        val arr = o.optJSONArray("rows")
        val rows =
            (0 until (arr?.length() ?: 0)).map { i ->
              val r = arr!!.getJSONObject(i)
              WidgetRow(r.optString("name"), r.optString("price"), r.optString("change"), r.optString("dir", "neutral"), r.optString("currency", ""))
            }
        WidgetPayload(o.optString("updatedLabel"), rows)
      } catch (e: Exception) {
        null
      }
    }
  }
}
