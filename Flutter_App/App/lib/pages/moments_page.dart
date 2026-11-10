import 'package:flutter/material.dart';
import '../utils/network_utils.dart';
import '../utils/list_utils.dart';

class MomentPage extends StatefulWidget {
  const MomentPage({super.key});

  @override
  State<MomentPage> createState() => _MomentPageState();
}

class _MomentPageState extends State<MomentPage> {
  // 朋友圈列表（强类型）
  List<Map<String, dynamic>> _momentList = [];
  bool _isLoading = true;
  String _errorMsg = '';
  int _pageIndex = 1;
  final int _pageSize = 10;

  // 加载朋友圈数据
  Future<void> _loadMomentList({bool isLoadMore = false}) async {
    if (isLoadMore) {
      setState(() => _pageIndex++);
    } else {
      setState(() {
        _isLoading = true;
        _errorMsg = '';
      });
    }
    //print('加载朋友圈数据...');

    try {
      final response = await NetworkServices.getMomentList(
        pageIndex: _pageIndex,
        pageSize: _pageSize,
      );
      print('加载朋友圈数据...getMomentList');

      if (response['code'] == 200) {
        List<dynamic> rawList = response['data']?['moments'] ?? [];
        List<Map<String, dynamic>> newList = ListUtils.toMapList(rawList);

        setState(() {
          _momentList = isLoadMore ? [..._momentList, ...newList] : newList;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMsg = response['message'] ?? '获取朋友圈失败';
          _isLoading = false;
          if (isLoadMore) _pageIndex--; // 加载更多失败，页码回退
        });
      }
    } catch (e) {
      setState(() {
        _errorMsg = '网络异常：$e';
        _isLoading = false;
        if (isLoadMore) _pageIndex--;
      });
    }
  }

  // 构建朋友圈图片网格
  Widget _buildImageGrid(List<dynamic> images) {
    if (images.isEmpty) return const SizedBox();

    int count = images.length;
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: count > 3 ? 3 : count,
      crossAxisSpacing: 4,
      mainAxisSpacing: 4,
      childAspectRatio: 1,
      children: images.map((imgUrl) {
        String url = imgUrl?.toString() ?? '';
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            image: DecorationImage(
              image: url.startsWith('http')
                  ? NetworkImage(url)
                  : AssetImage(url) as ImageProvider,
              fit: BoxFit.cover,
            ),
          ),
        );
      }).toList(),
    );
  }

  // 构建朋友圈列表项
  Widget _buildMomentItem(Map<String, dynamic> moment) {
    // 安全取值
    String username = MapUtils.getString(
      moment,
      'Username',
      defaultValue: '未知用户',
    );
    String avatar = MapUtils.getString(
      moment,
      'Avatar',
      defaultValue: 'assets/avatar_default.png',
    );
    String content = MapUtils.getString(moment, 'Content');
    List<dynamic> images = moment['Images'] is List ? moment['Images'] : [];
    String createTime = MapUtils.getString(
      moment,
      'CreateTime',
      defaultValue: '未知时间',
    );
    int likeCount = MapUtils.getInt(moment, 'LikeCount');
    int commentCount = MapUtils.getInt(moment, 'CommentCount');

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey[200]!,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 发布者信息
          Row(
            children: [
              CircleAvatar(
                backgroundImage: avatar.startsWith('http')
                    ? NetworkImage(avatar)
                    : const AssetImage('assets/avatar_default.png')
                          as ImageProvider,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      username,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      createTime,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // 朋友圈内容
          Text(content),
          const SizedBox(height: 8),
          // 图片网格
          _buildImageGrid(images),
          const SizedBox(height: 12),
          // 点赞/评论
          Row(
            children: [
              IconButton(
                onPressed: () {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('暂未实现点赞功能')));
                },
                icon: const Icon(Icons.favorite_border, color: Colors.grey),
                iconSize: 20,
              ),
              Text(
                '$likeCount',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
              const SizedBox(width: 16),
              IconButton(
                onPressed: () {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('暂未实现评论功能')));
                },
                icon: const Icon(Icons.comment_outlined, color: Colors.grey),
                iconSize: 20,
              ),
              Text(
                '$commentCount',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    // 初始化加载朋友圈
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadMomentList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('朋友圈'), elevation: 1),
      body: _isLoading
          ? // 加载中
            const Center(child: CircularProgressIndicator())
          : _errorMsg.isNotEmpty
          ? // 加载失败
            Center(
              child: Text(_errorMsg, style: const TextStyle(color: Colors.red)),
            )
          : _momentList.isEmpty
          ? // 无数据
            const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.photo_album_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text('暂无朋友圈动态', style: TextStyle(color: Colors.grey)),
                ],
              ),
            )
          : // 朋友圈列表（支持下拉刷新、上拉加载）
            RefreshIndicator(
              onRefresh: () => _loadMomentList(isLoadMore: false),
              child: ListView.builder(
                padding: const EdgeInsets.only(top: 8),
                itemCount: _momentList.length + 1, // +1 用于加载更多
                itemBuilder: (context, index) {
                  if (index == _momentList.length) {
                    // 加载更多占位
                    return _pageIndex > 1
                        ? const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Center(child: Text('已加载全部')),
                          )
                        : const SizedBox();
                  }
                  return _buildMomentItem(_momentList[index]);
                },
              ),
            ),
    );
  }
}
