import 'package:flutter/material.dart';
import '../../models/api_result.dart';
import '../theme/app_theme.dart';

class BillDetailsScreen extends StatelessWidget {
  final CityQueryResult result;
  final VoidCallback onBack; // 新增返回回調函數

  const BillDetailsScreen({
    Key? key,
    required this.result,
    required this.onBack, // 接收返回回調
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 返回按鈕
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              ElevatedButton.icon(
                onPressed: onBack,
                icon: const Icon(Icons.arrow_back),
                label: const Text("返回總覽"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade700,
                ),
              ),
            ],
          ),
        ),

        // 詳細內容
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSummaryCard(context),
                  const SizedBox(height: 16),

                  // 顯示未繳停車單
                  if (result.result != null && result.result!.bills.isNotEmpty) ...[
                    Text(
                      "未逾期停車單",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? AppTheme.darkTextSecondary
                            : null,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...result.result!.bills.map((bill) => _buildBillCard(bill, context)),
                    const SizedBox(height: 16),
                  ],

                  // 顯示催繳單
                  if (result.result != null && result.result!.reminders.isNotEmpty) ...[
                    Text(
                      "催繳單",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? AppTheme.darkTextSecondary
                            : null,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...result.result!.reminders.map((reminder) => _buildReminderCard(reminder, context)),
                    const SizedBox(height: 24), // 底部填充，確保最後一個項目不會被按鈕遮擋
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(BuildContext context) {
    // 定義標籤文字樣式 - 在黑暗模式下使用灰色
    final labelTextStyle = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 18,
      color: Theme.of(context).brightness == Brightness.dark
          ? AppTheme.darkTextSecondary
          : null,
    );

    final hasResult = result.result != null;
    final hasUnpaidBills = hasResult && result.result!.totalCount > 0;

    return Card(
      color: Theme.of(context).brightness == Brightness.dark
          ? (hasUnpaidBills ? AppTheme.errorColor.withOpacity(0.2) : AppTheme.successColor.withOpacity(0.1))
          : (hasUnpaidBills ? AppTheme.errorColorLight : AppTheme.successColorLight),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    "${result.city} 查詢結果",
                    style: labelTextStyle,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (hasResult)
                  Flexible(
                    child: Text(
                      "車號: ${result.result!.carId}",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? AppTheme.darkTextSecondary
                            : null,
                      ),
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.end,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            if (hasResult) ...[
              Text(
                "車種: ${result.result!.carTypeText}",
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppTheme.darkTextSecondary
                      : null,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "未繳筆數: ${result.result!.totalCount} 筆",
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppTheme.darkTextSecondary
                      : null,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "未繳總額: ${result.result!.totalAmount} 元",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: hasUnpaidBills ? AppTheme.errorColor :
                  Theme.of(context).brightness == Brightness.dark
                      ? AppTheme.darkTextSecondary
                      : null,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "資料更新時間: ${_formatDateTime(result.result!.updateTime)}",
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppTheme.darkTextSecondary
                      : AppTheme.textSecondary,
                ),
              ),
            ] else ...[
              Text(
                "訊息: ${result.message}",
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppTheme.darkTextSecondary
                      : null,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBillCard(ParkingBill bill, BuildContext context) {
    // 定義標籤文字樣式 - 在黑暗模式下使用灰色
    final labelTextStyle = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 16,
      color: Theme.of(context).brightness == Brightness.dark
          ? AppTheme.darkTextSecondary
          : null,
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    "停車單號: ${bill.billNo}",
                    style: labelTextStyle,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getBillStatusColor(bill.billStatus, context),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    bill.statusText,
                    style: TextStyle(
                      color: _getBillStatusTextColor(bill.billStatus),
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(),
            _buildInfoRow("停車日期", bill.parkingDate, context),
            _buildInfoRow("繳費期限", bill.payLimitDate, context),
            if (bill.parkingHours > 0)
              _buildInfoRow("停車時數", "${bill.parkingHours} 小時", context),
            _buildInfoRow("停車金額", "${bill.amount} 元", context),
            _buildInfoRow("應繳金額", "${bill.payAmount} 元", context,
                valueStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: bill.payAmount > 0 ? AppTheme.errorColor :
                  Theme.of(context).brightness == Brightness.dark
                      ? AppTheme.darkTextSecondary
                      : null,
                )),
            if (bill.location != null && bill.location!.isNotEmpty)
              _buildInfoRow("停車位置", bill.location!, context),
          ],
        ),
      ),
    );
  }

  Widget _buildReminderCard(Reminder reminder, BuildContext context) {
    // 定義標籤文字樣式 - 在黑暗模式下使用灰色
    final labelTextStyle = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 16,
      color: Theme.of(context).brightness == Brightness.dark
          ? AppTheme.darkTextSecondary
          : null,
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF3D3A2A) // 深色模式下的橙色背景
          : const Color(0xFFFFF3E0), // 淺色模式下的橙色背景
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    "催繳單號: ${reminder.reminderNo}",
                    style: labelTextStyle,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                if (reminder.isProsecuted == 1)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? AppTheme.errorColor.withOpacity(0.3)
                          : AppTheme.errorColorLight,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      "已告發",
                      style: TextStyle(
                        color: AppTheme.errorColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
              ],
            ),
            const Divider(),
            _buildInfoRow("催繳期限", reminder.reminderLimitDate, context),
            _buildInfoRow("停車總金額", "${reminder.amount} 元", context),
            _buildInfoRow("工本費", "${reminder.extraCharge} 元", context),
            _buildInfoRow("應繳總額", "${reminder.payAmount} 元", context,
                valueStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.errorColor,
                )),
            _buildInfoRow("告發狀態", reminder.prosecutedStatusText, context,
                valueStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: reminder.isProsecuted == 1 ? AppTheme.errorColor :
                  Theme.of(context).brightness == Brightness.dark
                      ? AppTheme.darkTextSecondary
                      : null,
                )),
            if (reminder.isProsecuted == 1 && reminder.prosecuteLimitDate.isNotEmpty)
              _buildInfoRow("告發期限", reminder.prosecuteLimitDate, context),

            // 顯示催繳單中的停車單明細
            if (reminder.bills.isNotEmpty) ...[
              const SizedBox(height: 8),
              const Divider(),
              Text(
                "包含以下逾期停車單:",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppTheme.darkTextSecondary
                      : null,
                ),
              ),
              const SizedBox(height: 8),
              ...reminder.bills.map((bill) => _buildIncludedBillRow(bill, context)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildIncludedBillRow(ParkingBill bill, BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? AppTheme.darkCardBackground
            : Colors.white,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "單號: ${bill.billNo}",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppTheme.darkTextSecondary
                        : null,
                  ),
                ),
                Text(
                  "日期: ${bill.parkingDate}",
                  style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppTheme.darkTextSecondary
                        : null,
                  ),
                ),
              ],
            ),
          ),
          Text(
            "${bill.amount} 元",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppTheme.errorColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, BuildContext context, {TextStyle? valueStyle}) {
    // 定義標籤文字樣式 - 在黑暗模式下使用灰色
    final labelStyle = TextStyle(
      fontWeight: FontWeight.bold,
      color: Theme.of(context).brightness == Brightness.dark
          ? AppTheme.darkTextSecondary
          : null,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start, // 從頂部對齊，讓長文字可以換行
        children: [
          Flexible(
            flex: 3,
            child: Text(
              label,
              style: labelStyle,
            ),
          ),
          const SizedBox(width: 8), // 加入間距確保文字不會太靠近
          Flexible(
            flex: 4,
            child: Text(
              value,
              style: valueStyle ?? (Theme.of(context).brightness == Brightness.dark
                  ? TextStyle(color: AppTheme.darkTextPrimary)
                  : null),
              softWrap: true, // 允許文字換行
              overflow: TextOverflow.visible, // 不裁剪溢出的文字
            ),
          ),
        ],
      ),
    );
  }

  // 獲取狀態顏色
  Color _getBillStatusColor(int status, BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    switch (status) {
      case 0:
        return isDark ? AppTheme.warningColor.withOpacity(0.3) : AppTheme.warningColorLight;
      case 1:
        return isDark ? const Color(0xFF3D3A2A) : const Color(0xFFFFF3E0);
      case 2:
        return isDark ? AppTheme.errorColor.withOpacity(0.3) : AppTheme.errorColorLight;
      case 3:
        return isDark ? Colors.grey.shade800 : Colors.grey.shade300;
      default:
        return isDark ? Colors.grey.shade800 : Colors.grey.shade200;
    }
  }

  // 獲取狀態文字顏色
  Color _getBillStatusTextColor(int status) {
    switch (status) {
      case 0:
        return Colors.orange.shade800;
      case 1:
        return Colors.deepOrange;
      case 2:
        return AppTheme.errorColor;
      case 3:
        return Colors.grey.shade700;
      default:
        return Colors.grey.shade600;
    }
  }

  // 格式化日期時間
  String _formatDateTime(String dateTime) {
    if (dateTime.isEmpty) return '';

    try {
      // 嘗試解析 ISO8601 格式
      DateTime dt = DateTime.parse(dateTime);
      return '${dt.year}/${dt.month.toString().padLeft(2, '0')}/${dt.day.toString().padLeft(2, '0')} '
          '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateTime; // 如果解析失敗，返回原始字符串
    }
  }
}