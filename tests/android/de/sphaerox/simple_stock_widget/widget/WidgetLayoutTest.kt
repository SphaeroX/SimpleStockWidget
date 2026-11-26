package de.sphaerox.simple_stock_widget.widget

import org.junit.Assert.assertEquals
import org.junit.Test

class WidgetLayoutTest {
  private val items = (1..14).map { "R$it" }

  @Test
  fun zweiSpaltenWerdenSpaltenweiseGefuellt() {
    val cols = WidgetLayout.split(items, columns = 2, rowsPerColumn = 7)
    assertEquals(listOf("R1", "R2", "R3", "R4", "R5", "R6", "R7"), cols[0])
    assertEquals(listOf("R8", "R9", "R10", "R11", "R12", "R13", "R14"), cols[1])
  }

  @Test
  fun wenigerEintraegeWerdenGleichmaessigVerteilt() {
    val cols = WidgetLayout.split(items.take(5), columns = 2, rowsPerColumn = 7)
    assertEquals(listOf("R1", "R2", "R3"), cols[0])
    assertEquals(listOf("R4", "R5"), cols[1])
  }

  @Test
  fun zuVieleEintraegeWerdenAbgeschnitten() {
    val cols = WidgetLayout.split(items, columns = 2, rowsPerColumn = 4)
    assertEquals(4, cols[0].size)
    assertEquals(listOf("R5", "R6", "R7", "R8"), cols[1])
  }

  @Test
  fun eineSpalte() {
    val cols = WidgetLayout.split(items.take(3), columns = 1, rowsPerColumn = 7)
    assertEquals(1, cols.size)
    assertEquals(listOf("R1", "R2", "R3"), cols[0])
  }

  @Test
  fun leereListe() {
    assertEquals(0, WidgetLayout.split(emptyList<String>(), columns = 2, rowsPerColumn = 7).flatten().size)
  }

  @Test
  fun spaltenzahlNachBreite() {
    assertEquals(1, WidgetLayout.columnCount(widthDp = 250f))
    assertEquals(2, WidgetLayout.columnCount(widthDp = 360f))
    assertEquals(2, WidgetLayout.columnCount(widthDp = 320f))
  }

  @Test
  fun sichtbareZeilenNachHoehe() {
    // 4x2-Widget (~180 dp hoch) muss 14 Einträge in 2 Spalten zeigen können.
    assertEquals(true, WidgetLayout.rowsPerColumn(heightDp = 180f) >= 7)
    assertEquals(1, WidgetLayout.rowsPerColumn(heightDp = 10f))
  }
}

class TextWidthTest {
  @Test
  fun kursbreiteIstRealistisch() {
    val w = WidgetLayout.textWidthDp("54.896,39", 13f)
    assertEquals(true, w in 50f..70f)
  }

  @Test
  fun ziffernBreiterAlsSatzzeichen() {
    assertEquals(true, WidgetLayout.textWidthDp("8888", 13f) > WidgetLayout.textWidthDp("8,.8", 13f))
  }

  @Test
  fun zweiSpaltenLassenPlatzFuerNamen() {
    // Typisches 4-Spalten-Widget (~360 dp), zweispaltig ohne Pfeile, Zahlen in 12 sp:
    // je Spalte bleibt Platz für ~8 Zeichen Name.
    val column = (360f - WidgetLayout.PADDING_DP - WidgetLayout.COLUMN_GAP_DP) / 2
    val rest = column - WidgetLayout.textWidthDp("54.896,39", 12f) - WidgetLayout.textWidthDp("-315,68", 12f) - 12f
    assertEquals(true, rest >= 50f)
  }
}
