package de.sphaerox.simple_stock_widget.widget

import org.json.JSONObject

/** Spiegel von lib/widget_sync/widget_keys.dart. */
object WidgetKeys {
  const val PAYLOAD = "ssw_payload"
}

data class WidgetRow(val name: String, val price: String, val change: String, val dir: String)

data class WidgetPayload(val updatedLabel: String, val rows: List<WidgetRow>) {
  companion object {
    fun parse(json: String?): WidgetPayload? {
      if (json.isNullOrBlank()) return null
      return try {
        val o = JSONObject(json)
        val arr = o.optJSONArray("rows")
        val rows = (0 until (arr?.length() ?: 0)).map { i ->
          val r = arr!!.getJSONObject(i)
          WidgetRow(r.optString("name"), r.optString("price"), r.optString("change"), r.optString("dir", "neutral"))
        }
        WidgetPayload(o.optString("updatedLabel"), rows)
      } catch (e: Exception) {
        null
      }
    }
  }
}
