import 'package:flutter/material.dart';
import 'dart:math' as math;

void main() {
  runApp(const MachiningCalculatorApp());
}

class MachiningCalculatorApp extends StatelessWidget {
  const MachiningCalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '切削参数计算器',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF1E3A8A),
        scaffoldBackgroundColor: const Color(0xFFF4F6F9),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E3A8A),
          primary: const Color(0xFF1E3A8A),
          secondary: const Color(0xFFF97316),
        ),
        cardTheme: CardTheme(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          color: Colors.white,
        ),
        useMaterial3: true,
      ),
      home: const MainNavigationScreen(),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 1; // 默认停留在计算页
  
  // 模拟历史记录数据源
  final List<Map<String, dynamic>> _historyList = [
    {
      'tool': '面铣刀 Φ125 - 8齿',
      'material': '45#钢 | 粗加工',
      'time': '2026-05-20 14:30',
      'S': '713',
      'F': '1426'
    },
    {
      'tool': '面铣刀 Φ100 - 6齿',
      'material': '40Cr | 粗加工',
      'time': '2026-05-20 10:15',
      'S': '638',
      'F': '1148'
    },
    {
      'tool': '立铣刀 Φ20 - 4刃',
      'material': '45#钢 | 细加工',
      'time': '2026-05-19 16:45',
      'S': '1820',
      'F': '1820'
    }
  ];

  void _addHistory(Map<String, dynamic> item) {
    setState(() {
      _historyList.insert(0, item);
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      const Center(child: Text('首页 / 功能导航', style: TextStyle(fontSize: 18))),
      CalculatorPage(onSaveHistory: _addHistory),
      const Center(child: Text('刀具库页面 (本地离线)', style: TextStyle(fontSize: 18))),
      HistoryPage(historyList: _historyList),
      const Center(child: Text('个人中心 / 设置', style: TextStyle(fontSize: 18))),
    ];

    return Scaffold(
      body: pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF1E3A8A),
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: '首页'),
          BottomNavigationBarItem(icon: Icon(Icons.calculate), label: '计算'),
          BottomNavigationBarItem(icon: Icon(Icons.build), label: '刀具库'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: '记录'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: '我的'),
        ],
      ),
    );
  }
}

class CalculatorPage extends StatefulWidget {
  final Function(Map<String, dynamic>) onSaveHistory;
  const CalculatorPage({super.key, required this.onSaveHistory});

  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  // 控制器与内置默认参数 (100% 还原用户设计稿面铣刀参数)
  final TextEditingController _diameterController = TextEditingController(text: '125');
  final TextEditingController _teethController = TextEditingController(text: '8');
  final TextEditingController _vcController = TextEditingController(text: '280');
  final TextEditingController _fzController = TextEditingController(text: '0.25');
  final TextEditingController _apController = TextEditingController(text: '4.0');
  final TextEditingController _aeController = TextEditingController(text: '75');

  String _selectedMaterial = '45#钢 / 中碳钢';
  String _processType = '粗加工';
  String _coolantType = '有切削液';

  int _spindleSpeed = 713; // 初始转速 S
  int _feedRate = 1426;     // 初始进给 F

  void _runCalculation() {
    double d = double.tryParse(_diameterController.text) ?? 0;
    int z = int.tryParse(_teethController.text) ?? 0;
    double vc = double.tryParse(_vcController.text) ?? 0;
    double fz = double.tryParse(_fzController.text) ?? 0;

    if (d > 0 && z > 0 && vc > 0 && fz > 0) {
      setState(() {
        // S = (Vc * 1000) / (pi * D)
        _spindleSpeed = ((vc * 1000) / (math.pi * d)).round();
        // F = S * Z * Fz
        _feedRate = (_spindleSpeed * z * fz).round();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('计算成功！推荐参数已更新'), duration: Duration(seconds: 1)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入正确的计算参数数值')),
      );
    }
  }

  void _triggerSave() {
    DateTime now = DateTime.now();
    String formattedTime = "${now.year}-${now.month.toString().padLeft(2,'0')}-${now.day.toString().padLeft(2,'0')} ${now.hour.toString().padLeft(2,'0')}:${now.minute.toString().padLeft(2,'0')}";
    
    widget.onSaveHistory({
      'tool': '面铣刀 Φ${_diameterController.text} - ${_teethController.text}齿',
      'material': '$_selectedMaterial | $_processType',
      'time': formattedTime,
      'S': '$_spindleSpeed',
      'F': '$_feedRate'
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('计算记录已保存到本地数据库！')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('切削参数计算器', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1E3A8A),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 顶部类别选择卡片
            Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: _buildTabHeaders(),
                ),
              ),
            ),
            const SizedBox(height: 8),

            // 图纸③：计算条件输入区域
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('计算条件输入页 (面铣刀)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A))),
                    const Divider(),
                    _buildMaterialDropdown(),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(child: _buildInputField('刀具直径 D (mm)', _diameterController)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildInputField('刀齿数 Z', _teethController)),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(child: _buildInputField('切削速度 Vc (m/min)', _vcController)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildInputField('每齿进给 Fz (mm/z)', _fzController)),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(child: _buildInputField('切深 Ap (mm)', _apController)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildInputField('侧吃刀 Ae (mm)', _aeController)),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildToggleGroup('加工方式', ['粗加工', '精加工'], _processType, (v) => setState(() => _processType = v)),
                        _buildToggleGroup('切削液', ['有切削液', '干切'], _coolantType, (v) => setState(() => _coolantType = v)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF97316),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: _runCalculation,
                        child: const Text('计 算 参 数', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),

            // 图纸④：计算结果展示区域
            Card(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(14.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.between,
                      children: [
                        const Text('计算结果', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                        Text('$_selectedMaterial | $_processType', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                      ],
                    ),
                    const Divider(),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(child: _buildResultGrid('转速 S (r/min)', '$_spindleSpeed', const Color(0xFFE8F5E9), const Color(0xFF2E7D32))),
                        const SizedBox(width: 12),
                        Expanded(child: _buildResultGrid('进给 F (mm/min)', '$_feedRate', const Color(0xFFE3F2FD), const Color(0xFF1565C0))),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(child: _buildResultGrid('每齿进给 Fz', _fzController.text, const Color(0xFFF3E5F5), const Color(0xFF6A1B9A))),
                        const SizedBox(width: 12),
                        Expanded(child: _buildResultGrid('切深 Ap (mm)', _apController.text, const Color(0xFFFFF3E0), const Color(0xFFEF6C00))),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        OutlinedButton.icon(onPressed: _triggerSave, icon: const Icon(Icons.bookmark_border), label: const Text('保存记录')),
                        OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.share), label: const Text('分享结果')),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildTabHeaders() {
    List<String> tabs = ['面铣刀', '立铣刀', '麻花钻', 'U钻'];
    return tabs.map((t) {
      bool isSelected = t == '面铣刀';
      return Text(
        t,
        style: TextStyle(
          fontSize: 13,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? const Color(0xFF1E3A8A) : Colors.grey,
        ),
      );
    }).toList();
  }

  Widget _buildMaterialDropdown() {
    return Row(
      children: [
        const Text('工件材料:  ', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
        Expanded(
          child: DropdownButton<String>(
            value: _selectedMaterial,
            isExpanded: true,
            style: const TextStyle(color: Colors.black87, fontSize: 13),
            items: <String>['45#钢 / 中碳钢', 'Q235 / 碳素结构钢', '40Cr / 合金结构钢', '304 / 不锈钢', 'TC4 / 钛合金']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(value: value, child: Text(value));
            }).toList(),
            onChanged: (String? newValue) {
              if (newValue != null) setState(() => _selectedMaterial = newValue);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildInputField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        style: const TextStyle(fontSize: 13),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(fontSize: 11),
          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
        ),
      ),
    );
  }

  Widget _buildToggleGroup(String label, List<String> options, String current, Function(String) onChanged) {
    return Row(
      children: [
        Text('$label: ', style: const TextStyle(fontSize: 11, color: Colors.grey)),
        const SizedBox(width: 4),
        ...options.map((opt) {
          bool isSel = opt == current;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2.0),
            child: ChoiceChip(
              label: Text(opt, style: TextStyle(fontSize: 10, color: isSel ? Colors.white : Colors.black87)),
              selected: isSel,
              selectedColor: const Color(0xFF1E3A8A),
              onSelected: (bool selected) {
                if (selected) onChanged(opt);
              },
            ),
          );
        }),
      ],
    );
  }

  Widget _buildResultGrid(String title, String value, Color bg, Color textCol) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 10, color: textCol.withOpacity(0.8))),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textCol)),
        ],
      ),
    );
  }
}

class HistoryPage extends StatelessWidget {
  final List<Map<String, dynamic>> historyList;
  const HistoryPage({super.key, required this.historyList});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('计算历史记录 (离线数据)', style: TextStyle(color: Colors.white, fontSize: 16)),
        backgroundColor: const Color(0xFF1E3A8A),
      ),
      body: historyList.isEmpty
          ? const Center(child: Text('暂无历史本地存储记录'))
          : ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: historyList.length,
              itemBuilder: (context, index) {
                final item = historyList[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  child: ListTile(
                    title: Text(item['tool'], style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                    subtitle: Text('${item['material']}\n${item['time']}', style: const TextStyle(fontSize: 11)),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('S: ${item['S']}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.green)),
                        Text('F: ${item['F']}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blue)),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
