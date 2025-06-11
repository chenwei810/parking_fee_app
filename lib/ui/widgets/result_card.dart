import 'package:flutter/material.dart';
import '../../models/api_result.dart';
import '../theme/app_theme.dart';

class ResultCard extends StatelessWidget {
  final CityQueryResult result;
  final VoidCallback onTap;

  const ResultCard({
    Key? key,
    required this.result,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 根據查詢狀態設置顏色
    Color statusColor = AppTheme.successColorLight;
    Color statusTextColor = AppTheme.successColor;
    IconData statusIcon = Icons.check_circle_outline;

    if (result.status == 'TIMEOUT') {
      statusColor = AppTheme.warningColorLight;
      statusTextColor = AppTheme.warningColor;
      statusIcon = Icons.timer_outlined;
    } else if (result.status != 'SUCCESS' && result.status != 'OK') {
      statusColor = AppTheme.errorColorLight;
      statusTextColor = AppTheme.errorColor;
      statusIcon = Icons.error_outline;
    }

    // 是否有未繳費
    final hasUnpaidBills = result.hasUnpaidBills;

    // 計算停車單和催繳單數量
    int billCount = 0;
    int reminderCount = 0;

    if (hasUnpaidBills && result.result != null) {
      billCount = result.result!.bills.length;
      reminderCount = result.result!.reminders.length;
    }

    // 定義標籤文字樣式 - 在黑暗模式下使用灰色
    final labelTextStyle = TextStyle(
      fontWeight: FontWeight.w600,
      fontSize: 16,
      color: Theme.of(context).brightness == Brightness.dark
          ? AppTheme.darkTextSecondary
          : null,
    );

    // 定義次要文字樣式 (用於小型說明文字)
    final subtitleTextStyle = TextStyle(
      fontSize: 11,
      color: Theme.of(context).brightness == Brightness.dark
          ? AppTheme.darkTextSecondary
          : AppTheme.textSecondary,
    );

    return Card(
      margin: const EdgeInsets.only(top: 8),
      elevation: 0.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
            color: Theme.of(context).brightness == Brightness.dark
                ? AppTheme.darkBorderColor
                : AppTheme.borderColor,
            width: 0.5
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
          child: Row(
            children: [
              // 城市名稱
              Expanded(
                flex: 2,
                child: Center(
                  child: Column(
                    children: [
                      Text(
                        result.city,
                        style: labelTextStyle,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 2),
                      Icon(
                        Icons.chevron_right,
                        size: 16,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? AppTheme.darkTextSecondary.withOpacity(0.7)
                            : AppTheme.textSecondary.withOpacity(0.7),
                      ),
                    ],
                  ),
                ),
              ),

              // 未繳筆數
              Expanded(
                flex: 2,
                child: hasUnpaidBills ?
                Column(
                  children: [
                    Text(
                      result.result!.totalCount.toString(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.errorColor,
                        fontSize: 17,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (billCount > 0 || reminderCount > 0)
                      Text(
                        '${billCount > 0 ? "$billCount筆單" : ""}${billCount > 0 && reminderCount > 0 ? ", " : ""}${reminderCount > 0 ? "$reminderCount筆催繳" : ""}',
                        style: subtitleTextStyle,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis, // 添加省略號處理
                      ),
                  ],
                ) :
                Text(
                  '-',
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppTheme.darkTextSecondary
                        : null,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              // 未繳總額
              Expanded(
                flex: 2,
                child: Text(
                  hasUnpaidBills
                      ? '${result.result!.totalAmount}'
                      : '-',
                  style: TextStyle(
                    fontWeight: hasUnpaidBills ? FontWeight.bold : FontWeight.normal,
                    color: hasUnpaidBills ? AppTheme.errorColor : Theme.of(context).brightness == Brightness.dark
                        ? AppTheme.darkTextSecondary
                        : null,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              // 狀態 - 使用較小字體顯示
              Expanded(
                flex: 2,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4), // 減少水平內邊距
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? statusColor.withOpacity(0.3)
                        : statusColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        statusIcon,
                        size: 12, // 縮小圖標尺寸
                        color: statusTextColor,
                      ),
                      const SizedBox(width: 2), // 減少間距
                      Flexible( // 使用 Flexible 包裹文字
                        child: Text(
                          result.status,
                          style: TextStyle(
                            color: statusTextColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 11, // 縮小字體
                          ),
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis, // 添加省略號處理
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}