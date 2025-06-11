import 'package:flutter/material.dart';

class CarPlateInput extends StatefulWidget {
  final Function(String) onCarPlateChanged;
  final String? initialValue;

  const CarPlateInput({
    Key? key,
    required this.onCarPlateChanged,
    this.initialValue,
  }) : super(key: key);

  @override
  State<CarPlateInput> createState() => _CarPlateInputState();
}

class _CarPlateInputState extends State<CarPlateInput> {
  final _firstPartController = TextEditingController();
  final _secondPartController = TextEditingController();
  final _firstPartFocusNode = FocusNode();
  final _secondPartFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    // 處理初始值
    if (widget.initialValue != null && widget.initialValue!.isNotEmpty) {
      final parts = widget.initialValue!.split('-');
      if (parts.length == 2) {
        _firstPartController.text = parts[0];
        _secondPartController.text = parts[1];
      } else {
        // 沒有分隔符號時，嘗試自動分割
        final value = widget.initialValue!.toUpperCase();
        RegExp numbersRegex = RegExp(r'\d+');
        RegExp lettersRegex = RegExp(r'[A-Z]+');

        final lettersMatches = lettersRegex.allMatches(value);
        final numbersMatches = numbersRegex.allMatches(value);

        if (lettersMatches.isNotEmpty && numbersMatches.isNotEmpty) {
          // 常見模式: 字母開頭，數字結尾 (例如 ABC123)
          if (value.startsWith(RegExp(r'[A-Z]'))) {
            final lastLetterIndex = value.lastIndexOfAny(['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z']);
            if (lastLetterIndex != -1 && lastLetterIndex < value.length - 1) {
              _firstPartController.text = value.substring(0, lastLetterIndex + 1);
              _secondPartController.text = value.substring(lastLetterIndex + 1);
            } else {
              _firstPartController.text = value;
            }
          }
          // 常見模式: 數字開頭，字母結尾 (例如 123ABC)
          else if (value.startsWith(RegExp(r'\d'))) {
            final firstLetterIndex = value.indexOf(RegExp(r'[A-Z]'));
            if (firstLetterIndex > 0) {
              _firstPartController.text = value.substring(0, firstLetterIndex);
              _secondPartController.text = value.substring(firstLetterIndex);
            } else {
              _firstPartController.text = value;
            }
          }
          // 其他情況
          else {
            _firstPartController.text = value;
          }
        } else {
          _firstPartController.text = value;
        }
      }
    }

    // 設置監聽事件
    _firstPartController.addListener(_updateCarPlate);
    _secondPartController.addListener(_updateCarPlate);
  }

  @override
  void dispose() {
    _firstPartController.dispose();
    _secondPartController.dispose();
    _firstPartFocusNode.dispose();
    _secondPartFocusNode.dispose();
    super.dispose();
  }

  void _updateCarPlate() {
    final firstPart = _firstPartController.text.trim().toUpperCase();
    final secondPart = _secondPartController.text.trim().toUpperCase();

    String plate = '';
    if (firstPart.isNotEmpty && secondPart.isNotEmpty) {
      plate = '$firstPart-$secondPart';
    } else if (firstPart.isNotEmpty) {
      plate = firstPart;
    } else if (secondPart.isNotEmpty) {
      plate = secondPart;
    }

    widget.onCarPlateChanged(plate);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // 第一部分
        Expanded(
          flex: 1,
          child: TextFormField(
            controller: _firstPartController,
            focusNode: _firstPartFocusNode,
            textCapitalization: TextCapitalization.characters,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: "車牌前碼",
              border: OutlineInputBorder(),
              floatingLabelBehavior: FloatingLabelBehavior.always, // 標籤永遠在線上方
              hintText: "例如: ABC",
              hintStyle: TextStyle(color: Colors.grey),
            ),
            onChanged: (value) {
              // 自動轉換為大寫
              if (value != value.toUpperCase()) {
                _firstPartController.value = _firstPartController.value.copyWith(
                  text: value.toUpperCase(),
                  selection: _firstPartController.selection,
                );
              }
              // 移除自動跳轉功能
            },
          ),
        ),

        // 分隔符
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: const Text(
            "-",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        // 第二部分
        Expanded(
          flex: 1,
          child: TextFormField(
            controller: _secondPartController,
            focusNode: _secondPartFocusNode,
            textCapitalization: TextCapitalization.characters,
            textInputAction: TextInputAction.done,
            decoration: const InputDecoration(
              labelText: "車牌後碼",
              border: OutlineInputBorder(),
              floatingLabelBehavior: FloatingLabelBehavior.always, // 標籤永遠在線上方
              hintText: "例如: 1234",
              hintStyle: TextStyle(color: Colors.grey),
            ),
            onChanged: (value) {
              // 自動轉換為大寫
              if (value != value.toUpperCase()) {
                _secondPartController.value = _secondPartController.value.copyWith(
                  text: value.toUpperCase(),
                  selection: _secondPartController.selection,
                );
              }
            },
          ),
        ),
      ],
    );
  }
}

extension StringExtension on String {
  int lastIndexOfAny(List<String> elements) {
    int lastIndex = -1;
    for (var element in elements) {
      final index = lastIndexOf(element);
      if (index > lastIndex) {
        lastIndex = index;
      }
    }
    return lastIndex;
  }
}