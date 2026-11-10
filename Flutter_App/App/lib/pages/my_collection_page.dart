import 'package:flutter/material.dart';
import '../utils/network_utils.dart';
class MyCollectionPage extends StatefulWidget {
  const MyCollectionPage({super.key});
  @override
  State<MyCollectionPage> createState() => _MyCollectionPage();
}

class _MyCollectionPage extends State<MyCollectionPage> {
  // 模拟收藏数据
  List<Map<String, dynamic>> _collections = [];
  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadCollections() async {
    setState(() {
      //_isLoading = true;
      //_errorMsg = '';
    });

    final response = await NetworkServices.getMyCollections(
      pageIndex: 1,
      pageSize: 10,
    );
    if (response['code'] == 200) {
      setState(() {
        List<dynamic> rawList = response['data']?['collections'] ?? [];
        // 步骤2：安全转换为 List<Map<String, dynamic>>
        List<Map<String, dynamic>> collections = rawList.map((item) {
          // 校验每个元素是否是Map，不是则返回空Map
          return item is Map<String, dynamic> ? item : <String, dynamic>{};
        }).toList();
        _collections = collections;
      });
    } else {
      setState(() {
        // _errorMsg = response['message'] ?? '查询收藏失败';
        // _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCollections();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('我的收藏'), elevation: 1),
      body: _collections.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    '暂无收藏内容',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _collections.length,
              itemBuilder: (context, index) {
                final item = _collections[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey[200]!,
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      //Icon(item['type'], color: Colors.red, size: 28),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['title'],
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item['createTime'],
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('收藏已删除')),
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
