import 'package:flutter/material.dart';
import '../../config/api_config.dart';
import '../theme/app_theme.dart';
import '../widgets/car_plate_input.dart';
import '../widgets/city_select_dialog.dart';

class CollapsibleSearchPanel extends StatefulWidget {
  final List<String> selectedCities;
  final String selectedCarType;
  final String carId;
  final bool isLoading;
  final Function(List<String>) onCitiesChanged;
  final Function(String) onCarTypeChanged;
  final Function(String) onCarIdChanged;
  final VoidCallback onSearch;

  const CollapsibleSearchPanel({
    Key? key,
    required this.selectedCities,
    required this.selectedCarType,
    required this.carId,
    required this.isLoading,
    required this.onCitiesChanged,
    required this.onCarTypeChanged,
    required this.onCarIdChanged,
    required this.onSearch,
  }) : super(key: key);

  @override
  State<CollapsibleSearchPanel> createState() => _CollapsibleSearchPanelState();
}

class _CollapsibleSearchPanelState extends State<CollapsibleSearchPanel> {
  bool _isExpanded = true;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16.0),
      child: _isExpanded
          ? _buildExpandedPanel()
          : _buildCollapsedPanel(),
    );
  }

  // 展開狀態的面板
  Widget _buildExpandedPanel() {
    return Column(
      children: [
        // 標題列 (展開狀態)
        _buildTitleRow(),

        // 查詢表單內容
        Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 縣市選擇與車輛類型
              Row(
                children: [
                  // 縣市選擇
                  Expanded(
                    flex: 2,
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: "查詢縣市",
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                      child: InkWell(
                        onTap: () => _showCitySelectionDialog(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Text(
                            _getCitySelectionText(),
                            style: TextStyle(
                              color: widget.selectedCities.isEmpty
                                  ? Theme.of(context).brightness == Brightness.dark
                                  ? Colors.grey.shade400
                                  : Colors.grey.shade600
                                  : Theme.of(context).brightness == Brightness.dark
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // 車輛類型
                  Expanded(
                    flex: 1,
                    child: DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: "車輛類型",
                        border: OutlineInputBorder(),
                      ),
                      value: widget.selectedCarType,
                      items: const [
                        DropdownMenuItem(
                          value: "C",
                          child: Text("汽車"),
                        ),
                        DropdownMenuItem(
                          value: "M",
                          child: Text("機車"),
                        ),
                        DropdownMenuItem(
                          value: "O",
                          child: Text("其他"),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          widget.onCarTypeChanged(value);
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 車牌輸入 - 使用新的分段輸入組件
              CarPlateInput(
                initialValue: widget.carId,
                onCarPlateChanged: widget.onCarIdChanged,
              ),
              const SizedBox(height: 16),

              // 查詢按鈕
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: widget.isLoading ? null : widget.onSearch,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text("查詢"),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 收合狀態的面板 (只有標題列)
  Widget _buildCollapsedPanel() {
    return _buildTitleRow();
  }

  // 標題列 (點擊可展開/收合)
  Widget _buildTitleRow() {
    return InkWell(
      onTap: () {
        setState(() {
          _isExpanded = !_isExpanded;
        });
      },
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "查詢資訊",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Icon(
              _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  // 獲取縣市選擇按鈕文字
  String _getCitySelectionText() {
    if (widget.selectedCities.isEmpty) {
      return "請選擇縣市";
    } else if (widget.selectedCities.length == ApiConfig.cityOrder.length) {
      return "全部縣市";
    } else if (widget.selectedCities.length <= 2) {
      return widget.selectedCities.join("、");
    } else {
      return "已選 ${widget.selectedCities.length} 個縣市";
    }
  }

  // 顯示縣市選擇對話框
  void _showCitySelectionDialog(BuildContext context) async {
    final result = await showDialog<List<String>>(
      context: context,
      builder: (context) => CitySelectDialog(
        selectedCities: widget.selectedCities,
      ),
    );

    if (result != null) {
      widget.onCitiesChanged(result);
    }
  }

  // 構建已選縣市的 Chip 列表
  Widget _buildSelectedCitiesChips() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: widget.selectedCities.map((city) {
        return Chip(
          label: Text(
            city,
            style: TextStyle(
              // 在黑暗模式下使用白色文字，否則使用預設顏色
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : AppTheme.errorColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          backgroundColor: Theme.of(context).brightness == Brightness.dark
              ? AppTheme.primaryColor.withOpacity(0.3)
              : AppTheme.primaryColorLight,
          deleteIcon: const Icon(Icons.cancel, size: 18),
          onDeleted: () {
            List<String> newList = List.from(widget.selectedCities);
            newList.remove(city);
            widget.onCitiesChanged(newList);
          },
        );
      }).toList(),
    );
  }
}