import 'package:flutter/material.dart';
import '../../config/api_config.dart';

class CitySelectDialog extends StatefulWidget {
  final List<String> selectedCities;

  const CitySelectDialog({
    Key? key,
    required this.selectedCities,
  }) : super(key: key);

  @override
  State<CitySelectDialog> createState() => _CitySelectDialogState();
}

class _CitySelectDialogState extends State<CitySelectDialog> {
  late List<String> _selectedCities;

  @override
  void initState() {
    super.initState();
    // 複製選中的城市列表，避免直接修改原始數據
    _selectedCities = List.from(widget.selectedCities);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('選擇查詢縣市'),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8), // 使用與其他輸入框相同的圓弧度
      ),
      content: SizedBox(
        width: double.maxFinite,
        height: MediaQuery.of(context).size.height * 0.5,
        child: Column(
          children: [
            // 全選/取消全選按鈕
            Row(
              children: [
                OutlinedButton(
                  onPressed: _selectAll,
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8), // 使用與其他輸入框相同的圓弧度
                    ),
                  ),
                  child: const Text('全選'),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: _deselectAll,
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8), // 使用與其他輸入框相同的圓弧度
                    ),
                  ),
                  child: const Text('取消全選'),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // 城市列表
            Expanded(
              child: ListView.builder(
                itemCount: ApiConfig.cityOrder.length,
                itemBuilder: (context, index) {
                  final city = ApiConfig.cityOrder[index];
                  return CheckboxListTile(
                    title: Text(city),
                    value: _selectedCities.contains(city),
                    onChanged: (bool? value) {
                      if (value == null) return;
                      setState(() {
                        if (value) {
                          if (!_selectedCities.contains(city)) {
                            _selectedCities.add(city);
                          }
                        } else {
                          _selectedCities.remove(city);
                        }
                      });
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8), // 使用與其他輸入框相同的圓弧度
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, _selectedCities),
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8), // 使用與其他輸入框相同的圓弧度
            ),
          ),
          child: const Text('確定'),
        ),
      ],
    );
  }

  void _selectAll() {
    setState(() {
      _selectedCities = List.from(ApiConfig.cityOrder);
    });
  }

  void _deselectAll() {
    setState(() {
      _selectedCities.clear();
    });
  }
}