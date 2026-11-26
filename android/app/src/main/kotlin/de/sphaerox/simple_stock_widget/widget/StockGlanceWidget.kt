package de.sphaerox.simple_stock_widget.widget

import android.content.Context
import androidx.compose.runtime.Composable
import androidx.compose.ui.unit.DpSize
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.glance.ColorFilter
import androidx.glance.GlanceId
import androidx.glance.GlanceModifier
import androidx.glance.Image
import androidx.glance.ImageProvider
import androidx.glance.LocalSize
import androidx.glance.action.Action
import androidx.glance.action.clickable
import androidx.glance.appwidget.GlanceAppWidget
import androidx.glance.appwidget.SizeMode
import androidx.glance.appwidget.action.actionRunCallback
import androidx.glance.appwidget.cornerRadius
import androidx.glance.appwidget.provideContent
import androidx.glance.background
import androidx.glance.currentState
import androidx.glance.layout.Alignment
import androidx.glance.layout.Box
import androidx.glance.layout.Column
import androidx.glance.layout.Row
import androidx.glance.layout.Spacer
import androidx.glance.layout.fillMaxHeight
import androidx.glance.layout.fillMaxSize
import androidx.glance.layout.fillMaxWidth
import androidx.glance.layout.height
import androidx.glance.layout.padding
import androidx.glance.layout.size
import androidx.glance.layout.width
import androidx.glance.text.FontWeight
import androidx.glance.text.Text
import androidx.glance.text.TextAlign
import androidx.glance.text.TextStyle
import de.sphaerox.simple_stock_widget.MainActivity
import de.sphaerox.simple_stock_widget.R
import es.antonborri.home_widget.HomeWidgetGlanceState
import es.antonborri.home_widget.HomeWidgetGlanceStateDefinition
import es.antonborri.home_widget.HomeWidgetPlugin
import es.antonborri.home_widget.actionStartActivity

class StockGlanceWidget : GlanceAppWidget() {
  override val stateDefinition = HomeWidgetGlanceStateDefinition()

  override val sizeMode =
      SizeMode.Responsive(
          setOf(
              DpSize(180.dp, 110.dp),
              DpSize(180.dp, 220.dp),
              DpSize(300.dp, 110.dp),
              DpSize(300.dp, 180.dp),
              DpSize(300.dp, 260.dp),
              DpSize(400.dp, 180.dp),
              DpSize(400.dp, 260.dp),
          ))

  override suspend fun provideGlance(context: Context, id: GlanceId) {
    provideContent {
      val prefs = currentState<HomeWidgetGlanceState>().preferences
      val payload = WidgetPayload.parse(prefs.getString(WidgetKeys.PAYLOAD, null))
      val now = System.currentTimeMillis()
      val loading = WidgetLayout.isLoading(prefs.getString(WidgetKeys.LOADING, null), now)
      val header = WidgetLayout.headerText(payload, prefs.getString(WidgetKeys.ERROR, null), now, loading)
      WidgetContent(payload, onOpen = actionStartActivity<MainActivity>(context), onReload = reloadAction(), loading = loading, header = header)
    }
  }

  override suspend fun providePreview(context: Context, widgetCategory: Int) {
    provideContent {
      val stored = WidgetPayload.parse(HomeWidgetPlugin.getData(context).getString(WidgetKeys.PAYLOAD, null))
      WidgetContent(stored ?: WidgetPayload.preview, onOpen = null, onReload = null)
    }
  }
}

internal fun reloadAction(): Action = actionRunCallback<ReloadAction>()

internal fun arrowFor(dir: String) =
    when (dir) {
      "up" -> "▲ "
      "down" -> "▼ "
      else -> ""
    }

private const val NAME_SP = 13
private const val ROW_SP = 12

@Composable
internal fun WidgetContent(
    payload: WidgetPayload?,
    onOpen: Action?,
    onReload: Action?,
    loading: Boolean = false,
    header: HeaderText = WidgetLayout.headerText(payload, null, 0L, loading),
) {
  val size = LocalSize.current
  var root = GlanceModifier.fillMaxSize().background(WidgetColors.background).cornerRadius(20.dp).padding(12.dp)
  if (onOpen != null) root = root.clickable(onOpen)
  Column(modifier = root) {
    Header(header, if (loading) null else onReload, loading)
    Spacer(GlanceModifier.height(WidgetLayout.HEADER_GAP_DP.dp))
    val rows = payload?.rows.orEmpty()
    if (rows.isEmpty()) {
      Text("In der App Werte hinzufügen", style = TextStyle(color = WidgetColors.secondary, fontSize = 13.sp))
      return@Column
    }
    val columns = WidgetLayout.columnCount(size.width.value)
    val split = WidgetLayout.split(rows, columns, WidgetLayout.rowsPerColumn(size.height.value))
    val showArrows = columns == 1
    val priceWidth = (rows.maxOf { WidgetLayout.textWidthDp(it.price, ROW_SP.toFloat()) } + 6f).dp
    val changeWidth =
        (rows.maxOf { WidgetLayout.textWidthDp((if (showArrows) arrowFor(it.dir) else "") + it.change, ROW_SP.toFloat()) } + 6f).dp
    Row(modifier = GlanceModifier.fillMaxWidth()) {
      split.forEachIndexed { index, column ->
        if (index > 0) Spacer(GlanceModifier.width(WidgetLayout.COLUMN_GAP_DP.dp))
        Column(modifier = GlanceModifier.defaultWeight().fillMaxHeight()) {
          column.forEach { RowLine(it, priceWidth, changeWidth, showArrows) }
        }
      }
    }
  }
}

@Composable
private fun Header(header: HeaderText, onReload: Action?, loading: Boolean) {
  Row(modifier = GlanceModifier.fillMaxWidth().height(WidgetLayout.HEADER_DP.dp), verticalAlignment = Alignment.CenterVertically) {
    Text(
        header.text,
        style =
            TextStyle(
                color = if (header.warning) WidgetColors.negative else WidgetColors.secondary,
                fontSize = 12.sp,
                fontWeight = if (header.warning) FontWeight.Medium else FontWeight.Normal,
            ),
        maxLines = 1,
        modifier = GlanceModifier.defaultWeight(),
    )
    var icon = GlanceModifier.size(24.dp).padding(2.dp)
    if (onReload != null) icon = icon.clickable(onReload)
    Box(modifier = icon, contentAlignment = Alignment.Center) {
      Image(
          provider = ImageProvider(R.drawable.ic_widget_refresh),
          contentDescription = "Aktualisieren",
          colorFilter = ColorFilter.tint(if (loading) WidgetColors.divider else WidgetColors.secondary),
          modifier = GlanceModifier.size(20.dp),
      )
    }
  }
}

@Composable
private fun RowLine(
    row: WidgetRow,
    priceWidth: androidx.compose.ui.unit.Dp,
    changeWidth: androidx.compose.ui.unit.Dp,
    showArrow: Boolean,
) {
  val color =
      when (row.dir) {
        "up" -> WidgetColors.positive
        "down" -> WidgetColors.negative
        else -> WidgetColors.neutral
      }
  val arrow = if (showArrow) arrowFor(row.dir) else ""
  val textColor = if (row.dim || row.error) WidgetColors.secondary else WidgetColors.text
  Row(modifier = GlanceModifier.fillMaxWidth().height(WidgetLayout.ROW_DP.dp), verticalAlignment = Alignment.CenterVertically) {
    Text(
        row.name,
        maxLines = 1,
        style = TextStyle(color = textColor, fontSize = NAME_SP.sp, fontWeight = FontWeight.Medium),
        modifier = GlanceModifier.defaultWeight(),
    )
    Text(
        row.price,
        maxLines = 1,
        style = TextStyle(color = textColor, fontSize = ROW_SP.sp, textAlign = TextAlign.End),
        modifier = GlanceModifier.width(priceWidth),
    )
    Text(
        arrow + row.change,
        maxLines = 1,
        style = TextStyle(color = color, fontSize = ROW_SP.sp, textAlign = TextAlign.End),
        modifier = GlanceModifier.width(changeWidth),
    )
  }
}
