package de.sphaerox.simple_stock_widget.widget

import kotlin.math.ceil
import kotlin.math.floor
import kotlin.math.max
import kotlin.math.min

/** Reine Layout-Logik des Widgets (ohne Glance-Abhängigkeit, unit-getestet). */
/** Kopfzeilentext und ob er als Warnung (z. B. Offline, veraltet) hervorgehoben wird. */
data class HeaderText(val text: String, val warning: Boolean)

object WidgetLayout {
  const val HEADER_DP = 24f
  const val PADDING_DP = 24f
  const val ROW_DP = 18f
  const val HEADER_GAP_DP = 4f
  const val TWO_COLUMN_MIN_WIDTH_DP = 300f
  const val COLUMN_GAP_DP = 12f

  fun columnCount(widthDp: Float): Int = if (widthDp >= TWO_COLUMN_MIN_WIDTH_DP) 2 else 1

  fun rowsPerColumn(heightDp: Float): Int = max(1, floor((heightDp - HEADER_DP - HEADER_GAP_DP - PADDING_DP) / ROW_DP).toInt())

  /** Verteilt [items] spaltenweise (links von oben nach unten, dann rechts); Überzähliges wird abgeschnitten. */
  fun <T> split(items: List<T>, columns: Int, rowsPerColumn: Int): List<List<T>> {
    if (items.isEmpty()) return List(columns) { emptyList() }
    val visible = items.take(columns * rowsPerColumn)
    val perColumn = min(rowsPerColumn, ceil(visible.size / columns.toDouble()).toInt())
    return List(columns) { c -> visible.drop(c * perColumn).take(perColumn) }
  }

  /** Geschätzte Textbreite in dp für Roboto bei [sp] (Ziffern ~0,56 em, Satzzeichen schmaler). */
  fun textWidthDp(text: String, sp: Float): Float =
      text.sumOf { c ->
        val em =
            when {
              c.isDigit() -> 0.56
              c == '.' || c == ',' || c == ' ' -> 0.27
              c == '+' || c == '-' -> 0.5
              c == '%' -> 0.85
              c == '▲' || c == '▼' -> 0.6
              c.isUpperCase() -> 0.65
              else -> 0.52
            }
        em
      }.toFloat() * sp

  /** Läuft gerade ein Refresh? [loadingValue] ist der Zeitstempel (ms) aus WidgetKeys.LOADING. */
  fun isLoading(loadingValue: String?, nowMs: Long, staleAfterMs: Long = 60_000L): Boolean {
    val started = loadingValue?.toLongOrNull() ?: return false
    return nowMs - started in 0 until staleAfterMs
  }

  /** Wählt die Kopfzeile: Laden > Fehler > veraltet > normal. Texte kommen fertig aus Dart. */
  fun headerText(payload: WidgetPayload?, error: String?, nowMs: Long, loading: Boolean): HeaderText {
    if (loading) return HeaderText("Aktualisiere …", false)
    if (!error.isNullOrBlank()) return HeaderText(error, true)
    val staleAt = payload?.staleAtMs
    if (payload != null && staleAt != null && nowMs > staleAt && payload.staleLabel != null) {
      return HeaderText(payload.staleLabel, true)
    }
    return HeaderText("Letzter Abruf: ${payload?.updatedLabel?.ifEmpty { null } ?: "–"}", false)
  }
}
