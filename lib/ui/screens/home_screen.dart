import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../models/api_result.dart';
import '../../services/api_service.dart';
import '../theme/app_theme.dart';
import '../theme/theme_provider.dart';
import '../widgets/result_card.dart';
import '../widgets/bill_details.dart';
import '../widgets/collapsible_search_panel.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  String _carId = '';
  List<String> _selectedCities = [];
  String _selectedCarType = "C"; // 預設汽車
  bool _isLoading = false;
  int _progress = 0;
  String _progressText = "";
  List<CityQueryResult> _results = [];
  CityQueryResult? _selectedResult;
  final ApiService _apiService = ApiService();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // 設置狀態欄顏色為淺色
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    // 初始化動畫控制器
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // 格式化車牌
  String _formatCarId(String carId) {
    // 轉為大寫
    carId = carId.toUpperCase();

    // 移除所有空格
    carId = carId.replaceAll(" ", "");

    // 返回處理後的車牌
    return carId;
  }

  @override
  Widget build(BuildContext context) {
    // 獲取 ThemeProvider
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("停車繳費查詢"),
        centerTitle: true,
        elevation: 0,
        // 在左側添加主題切換按鈕
        leading: IconButton(
          icon: Icon(
            themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
            color: Theme.of(context).appBarTheme.iconTheme?.color,
          ),
          onPressed: () {
            themeProvider.toggleTheme();
          },
          tooltip: themeProvider.isDarkMode ? '切換至亮色模式' : '切換至深色模式',
        ),
        actions: [
          if (_results.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _clearResults,
              tooltip: '清除結果',
            ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        // Wrap the Column with a SafeArea to avoid system UI overlaps
        child: SafeArea(
          child: Column(
            children: [
              // 使用可收合的查詢面板替代原有的查詢表單
              CollapsibleSearchPanel(
                selectedCities: _selectedCities,
                selectedCarType: _selectedCarType,
                carId: _carId,
                isLoading: _isLoading,
                onCitiesChanged: (cities) {
                  setState(() {
                    _selectedCities = cities;
                  });
                },
                onCarTypeChanged: (carType) {
                  setState(() {
                    _selectedCarType = carType;
                  });
                },
                onCarIdChanged: (carId) {
                  _carId = carId;
                },
                onSearch: _startQuery,
              ),

              _buildProgressBar(),

              // Use Expanded to ensure the list takes available space without overflow
              Expanded(
                child: _selectedResult != null
                    ? _buildDetailView()
                    : _buildResultsList(),
              ),

              // 添加 Copyright 信息在底部
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 6.0),
                alignment: Alignment.center,
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppTheme.darkCardBackground
                    : Colors.grey.shade50,
                child: Text(
                  "© 2025 異采整合行銷 https://myworks2.com/",
                  style: TextStyle(
                    fontSize: 10,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppTheme.darkTextSecondary
                        : AppTheme.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: _isLoading ? 50 : 0,
      child: Visibility(
        visible: _isLoading,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: _progress / 100,
                backgroundColor: Colors.grey[200],
                minHeight: 6,
                borderRadius: BorderRadius.circular(3),
              ),
              const SizedBox(height: 8),
              Text(
                _progressText,
                style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultsList() {
    if (_isLoading && _results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                strokeWidth: 3,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "查詢中...",
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppTheme.textSecondary),
            ),
          ],
        ),
      );
    }

    if (_results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search,
              size: 64,
              color: AppTheme.textSecondary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              "請輸入車牌資訊並點擊查詢按鈕",
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppTheme.textSecondary),
            ),
          ],
        ),
      );
    }

    // 計算統計信息
    int totalUnpaidCount = 0;
    int totalUnpaidAmount = 0;
    List<String> unpaidCities = [];

    for (var result in _results) {
      if (result.hasUnpaidBills) {
        totalUnpaidCount += result.result!.totalCount;
        totalUnpaidAmount += result.result!.totalAmount;
        unpaidCities.add(result.city);
      }
    }

    // 使用 ListView 代替 Column，讓所有內容都可以滾動
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      children: [
        // 摘要卡片
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: _buildSummaryCard(totalUnpaidCount, totalUnpaidAmount, unpaidCities),
        ),

        // 結果列表標題
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: AppTheme.separatorColor,
                width: 0.5,
              ),
            ),
          ),
          child: Row(
            children: const [
              Expanded(
                flex: 2,
                child: Text(
                  "縣市",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  "未繳筆數",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  "未繳總額",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  "狀態",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),

        // 結果列表
        for (var result in _results)
          ResultCard(
            result: result,
            onTap: () {
              setState(() {
                _selectedResult = result;
              });
            },
          ),

        // 底部填充，確保最後一個項目不會被按鈕遮擋
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildSummaryCard(int totalCount, int totalAmount, List<String> unpaidCities) {
    final hasUnpaidBills = totalCount > 0;
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    return Card(
      elevation: 0.5,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(color: AppTheme.borderColor, width: 0.5),
      ),
      child: Padding(
        padding: EdgeInsets.all(isLandscape ? 12.0 : 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  hasUnpaidBills ? Icons.warning_rounded : Icons.check_circle,
                  color: hasUnpaidBills ? AppTheme.warningColor : AppTheme.successColor,
                  size: isLandscape ? 20 : 24,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    hasUnpaidBills
                        ? "發現有未繳停車費！"
                        : "恭喜！沒有發現任何未繳停車費。",
                    style: TextStyle(
                      fontSize: isLandscape ? 15 : 17,
                      fontWeight: FontWeight.w600,
                      color: hasUnpaidBills
                          ? AppTheme.warningColor
                          : AppTheme.successColor,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: isLandscape ? 8 : 12),
            if (hasUnpaidBills) ...[
              Text(
                "發現共有 ${unpaidCities.length} 個縣市有未繳停車費",
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: isLandscape ? 13 : 15,
                ),
              ),
              SizedBox(height: isLandscape ? 2 : 4),
              // 在水平模式下使用更緊湊的布局
              isLandscape
                  ? _buildLandscapeSummaryContent(totalCount, totalAmount, unpaidCities)
                  : _buildPortraitSummaryContent(totalCount, totalAmount, unpaidCities),
            ],
          ],
        ),
      ),
    );
  }

  // 水平模式下的摘要內容佈局
  Widget _buildLandscapeSummaryContent(int totalCount, int totalAmount, List<String> unpaidCities) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 左側：未繳筆數和未繳總額
        Expanded(
          flex: 2,
          child: Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.errorColorLight,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Column(
                    children: [
                      Text(
                        "$totalCount",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.errorColor,
                        ),
                      ),
                      const Text(
                        "未繳筆數",
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.errorColorLight,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Column(
                    children: [
                      Text(
                        "$totalAmount",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.errorColor,
                        ),
                      ),
                      const Text(
                        "未繳總額",
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        // 右側：未繳費用的縣市
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "有未繳費用的縣市:",
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              Flexible(
                child: SingleChildScrollView(
                  child: Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: unpaidCities.map((city) {
                      return Chip(
                        label: Text(
                          city,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppTheme.errorColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        backgroundColor: AppTheme.errorColorLight,
                        labelPadding: EdgeInsets.zero,
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 豎直模式下的摘要內容佈局
  Widget _buildPortraitSummaryContent(int totalCount, int totalAmount, List<String> unpaidCities) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.errorColorLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Text(
                      "$totalCount",
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.errorColor,
                      ),
                    ),
                    const Text(
                      "未繳筆數",
                      style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.errorColorLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Text(
                      "$totalAmount",
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.errorColor,
                      ),
                    ),
                    const Text(
                      "未繳總額",
                      style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const Text(
          "有未繳費用的縣市:",
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 6),
        // 限制高度並使用捲動視圖
        ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.2,
          ),
          child: SingleChildScrollView(
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: unpaidCities.map((city) {
                return Chip(
                  label: Text(city),
                  backgroundColor: AppTheme.errorColorLight,
                  labelStyle: const TextStyle(
                    color: AppTheme.errorColor,
                    fontWeight: FontWeight.w500,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailView() {
    // 使用 BillDetailsScreen，並傳入返回回調函數
    return BillDetailsScreen(
      result: _selectedResult!,
      onBack: () {
        setState(() {
          _selectedResult = null;
        });
      },
    );
  }

  void _startQuery() async {
    if (_carId.isEmpty) {
      _showErrorDialog("請輸入車牌號碼");
      return;
    }

    // 格式化車牌
    final formattedCarId = _formatCarId(_carId);

    // 如果未選擇任何縣市，詢問是否查詢全部
    if (_selectedCities.isEmpty) {
      final shouldQueryAll = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("確認查詢"),
          content: const Text("您沒有選擇任何縣市，是否要查詢全部縣市？"),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("取消"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("確定"),
            ),
          ],
        ),
      );

      if (shouldQueryAll != true) return;
    }

    setState(() {
      _isLoading = true;
      _progress = 0;
      _progressText = "準備查詢${_selectedCities.isEmpty ? "全台各" : "選定"}縣市停車費資訊";
      _results = [];
      _selectedResult = null;
    });

    try {
      // 模擬進度更新
      _startProgressSimulation();

      // 執行查詢
      final results = await _apiService.queryMultipleCities(
        formattedCarId,
        _selectedCarType,
        selectedCities: _selectedCities.isEmpty ? null : _selectedCities,
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
          _results = results;
          _progress = 100;
          _progressText = "查詢完成";
        });

        // 查詢完成後的統計
        _showQueryCompletedDialog(results);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _showErrorDialog("查詢過程中發生錯誤: $e");
      }
    }
  }

  void _startProgressSimulation() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_isLoading && mounted) {
        setState(() {
          _progress = 10;
          _progressText = "查詢進度: 10%";
        });

        Future.delayed(const Duration(milliseconds: 500), () {
          if (_isLoading && mounted) {
            setState(() {
              _progress = 30;
              _progressText = "查詢進度: 30%";
            });

            Future.delayed(const Duration(milliseconds: 700), () {
              if (_isLoading && mounted) {
                setState(() {
                  _progress = 60;
                  _progressText = "查詢進度: 60%";
                });

                Future.delayed(const Duration(milliseconds: 900), () {
                  if (_isLoading && mounted) {
                    setState(() {
                      _progress = 80;
                      _progressText = "查詢進度: 80%";
                    });
                  }
                });
              }
            });
          }
        });
      }
    });
  }

  void _clearResults() {
    setState(() {
      _results = [];
      _selectedResult = null;
    });
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.error_outline, color: AppTheme.errorColor, size: 24),
            const SizedBox(width: 10),
            const Text("錯誤"),
          ],
        ),
        content: Text(message),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("確定"),
          ),
        ],
      ),
    );
  }

  void _showQueryCompletedDialog(List<CityQueryResult> results) {
    // 計算欠費縣市數量
    int billCities = 0;
    for (var result in results) {
      if (result.hasUnpaidBills) {
        billCities++;
      }
    }

    if (billCities > 0) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Row(
            children: [
              Icon(Icons.info_outline, color: AppTheme.warningColor, size: 24),
              const SizedBox(width: 10),
              const Text("查詢結果"),
            ],
          ),
          content: Text("發現 $billCities 個縣市有未繳停車費，請查看詳細資訊。"),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("確定"),
            ),
          ],
        ),
      );
    }
  }
}