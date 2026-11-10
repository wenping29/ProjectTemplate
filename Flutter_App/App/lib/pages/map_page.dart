import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AddMapPage extends StatefulWidget {
  const AddMapPage({super.key});

  @override
  State<AddMapPage> createState() => _AddMapPageState();
}

class _AddMapPageState extends State<AddMapPage> {
  late MapController _mapController;
  LatLng? _currentLocation;
  LatLng? _selectedLocation;
  final Location _location = Location();
  final String tiandituKey = "505d9689756a10fb34f1361c1cec5212";

  // 底图：vec矢量、img卫星、ter地形
  String _baseMapType = "vec";

  // 叠加图层开关
  bool _showLabel = true;
  bool _showRoad = false;
  bool _showDistrict = false;
  bool _show3DBuild = false;

  // 搜索
  final TextEditingController _searchCtrl = TextEditingController();
  List<dynamic> _searchResults = [];

  // 绘制
  String drawMode = "";
  List<LatLng> _drawPoints = [];
  List<Polyline> _polylines = [];
  List<Polygon> _polygons = [];
  List<Marker> _pointMarkers = [];

  // 测量
  double? _distance;
  double? _area;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _initLocation();
  }

  // 定位
  Future<void> _initLocation() async {
    var status = await Permission.location.request();
    if (!status.isGranted) return;
    LocationData loc = await _location.getLocation();
    //print(loc);
    setState(() {
      _currentLocation = LatLng(loc.latitude!, loc.longitude!);
      _selectedLocation = _currentLocation;
    });
    //_mapController.move(_currentLocation!, 16);
  }

  // 搜索地点
  Future<void> searchPlace(String key) async {
    if (key.isEmpty) return;
    try {
      final url =
          "https://api.tianditu.gov.cn/v2/search?keyword=$key&tk=$tiandituKey";
      final res = await http.get(Uri.parse(url));
      final data = jsonDecode(res.body);
      setState(() => _searchResults = data["pois"] ?? []);
    } catch (e) {
      setState(() => _searchResults = []);
    }
  }

  // 逆地理编码：经纬度 → 地址
  Future<String> reverseGeo(LatLng p) async {
    try {
      final url =
          "https://api.tianditu.gov.cn/geocoder?type=reverse&lon=${p.longitude}&lat=${p.latitude}&tk=$tiandituKey";
      final res = await http.get(Uri.parse(url));
      final data = jsonDecode(res.body);
      return data["result"]?["formatted_address"] ?? "未知地址";
    } catch (e) {
      return "获取地址失败";
    }
  }

  // 计算距离
  double calcDist(List<LatLng> pts) {
    double d = 0;
    final dist = Distance();
    for (int i = 0; i < pts.length - 1; i++) {
      d += dist.as(LengthUnit.Meter, pts[i], pts[i + 1]);
    }
    return d;
  }

  // 计算面积
  double calcArea(List<LatLng> pts) {
    if (pts.length < 3) return 0;
    num a = 0;
    for (int i = 0; i < pts.length; i++) {
      int j = (i + 1) % pts.length;
      a +=
          pts[i].longitude * pts[j].latitude -
          pts[j].longitude * pts[i].latitude;
    }
    return a.abs() / 2.0;
  }

  // 地图点击
  void onMapTap(LatLng p) {
    if (drawMode == "point") {
      setState(
        () => _pointMarkers.add(
          Marker(
            point: p,
            width: 30,
            height: 30,
            child: const Icon(Icons.location_on, color: Colors.green, size: 24),
          ),
        ),
      );
    } else if (drawMode == "polyline" || drawMode == "polygon") {
      setState(() => _drawPoints.add(p));
    } else {
      setState(() => _selectedLocation = p);
    }
  }

  // 完成绘制
  void finishDraw() {
    if (drawMode == "polyline" && _drawPoints.length >= 2) {
      setState(() {
        _polylines.add(
          Polyline(
            points: List.from(_drawPoints),
            color: Colors.blue,
            strokeWidth: 3,
          ),
        );
        _distance = calcDist(_drawPoints);
        _drawPoints.clear();
      });
    } else if (drawMode == "polygon" && _drawPoints.length >= 3) {
      setState(() {
        _polygons.add(
          Polygon(
            points: List.from(_drawPoints),
            color: Colors.orange.withOpacity(0.3),
            borderColor: Colors.orange,
            borderStrokeWidth: 2,
          ),
        );
        _area = calcArea(_drawPoints);
        _drawPoints.clear();
      });
    }
    setState(() => drawMode = "");
  }

  // 清空绘制
  void clearDraw() {
    setState(() {
      _drawPoints.clear();
      _polylines.clear();
      _polygons.clear();
      _pointMarkers.clear();
      _distance = null;
      _area = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text("地图新增（完整版）"),
      //   actions: [
      //     TextButton(
      //       onPressed: _selectedLocation == null
      //           ? null
      //           : () async {
      //               final addr = await reverseGeo(_selectedLocation!);
      //               // ignore: avoid_print
      //               print("保存：${_selectedLocation!}\n地址：$addr");
      //               Navigator.pop(context);
      //             },
      //       child: const Text("保存", style: TextStyle(color: Colors.white)),
      //     ),
      //   ],
      // ),
      body: _currentLocation == null
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _currentLocation!,
                    initialZoom: 16,
                    minZoom: 3,
                    maxZoom: 19,
                    onTap: (_, p) => onMapTap(p),
                  ),
                  children: [
                    // ========== 底图 ==========
                    if (_baseMapType == "vec")
                      TileLayer(
                        urlTemplate:
                            "https://t{s}.tianditu.gov.cn/DataServer?T=vec_w&x={x}&y={y}&l={z}&tk=$tiandituKey",
                        subdomains: const [
                          '0',
                          '1',
                          '2',
                          '3',
                          '4',
                          '5',
                          '6',
                          '7',
                        ],
                      ),
                    if (_baseMapType == "img")
                      TileLayer(
                        urlTemplate:
                            "https://t{s}.tianditu.gov.cn/DataServer?T=img_w&x={x}&y={y}&l={z}&tk=$tiandituKey",
                        subdomains: const [
                          '0',
                          '1',
                          '2',
                          '3',
                          '4',
                          '5',
                          '6',
                          '7',
                        ],
                      ),
                    if (_baseMapType == "ter")
                      TileLayer(
                        urlTemplate:
                            "https://t{s}.tianditu.gov.cn/DataServer?T=ter_w&x={x}&y={y}&l={z}&tk=$tiandituKey",
                        subdomains: const [
                          '0',
                          '1',
                          '2',
                          '3',
                          '4',
                          '5',
                          '6',
                          '7',
                        ],
                      ),

                    // ========== 注记 ==========
                    if (_showLabel)
                      TileLayer(
                        urlTemplate: _baseMapType == "vec"
                            ? "https://t{s}.tianditu.gov.cn/DataServer?T=cva_w&x={x}&y={y}&l={z}&tk=$tiandituKey"
                            : "https://t{s}.tianditu.gov.cn/DataServer?T=cia_w&x={x}&y={y}&l={z}&tk=$tiandituKey",
                        subdomains: const [
                          '0',
                          '1',
                          '2',
                          '3',
                          '4',
                          '5',
                          '6',
                          '7',
                        ],
                      ),

                    // 路网
                    if (_showRoad)
                      TileLayer(
                        urlTemplate:
                            "https://t{s}.tianditu.gov.cn/DataServer?T=rd_w&x={x}&y={y}&l={z}&tk=$tiandituKey",
                        subdomains: const [
                          '0',
                          '1',
                          '2',
                          '3',
                          '4',
                          '5',
                          '6',
                          '7',
                        ],
                      ),

                    // 行政区
                    if (_showDistrict)
                      TileLayer(
                        urlTemplate:
                            "https://t{s}.tianditu.gov.cn/DataServer?T=ibo_w&x={x}&y={y}&l={z}&tk=$tiandituKey",
                        subdomains: const [
                          '0',
                          '1',
                          '2',
                          '3',
                          '4',
                          '5',
                          '6',
                          '7',
                        ],
                      ),

                    // 3D建筑
                    if (_show3DBuild)
                      TileLayer(
                        urlTemplate:
                            "https://t{s}.tianditu.gov.cn/DataServer?T=bnd_w&x={x}&y={y}&l={z}&tk=$tiandituKey",
                        subdomains: const [
                          '0',
                          '1',
                          '2',
                          '3',
                          '4',
                          '5',
                          '6',
                          '7',
                        ],
                      ),

                    // 绘制元素
                    MarkerLayer(markers: _pointMarkers),
                    PolylineLayer(polylines: _polylines),
                    PolygonLayer(polygons: _polygons),

                    // 正在绘制的临时线
                    if (_drawPoints.isNotEmpty)
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: _drawPoints,
                            color: Colors.red,
                            strokeWidth: 2,
                          ),
                        ],
                      ),

                    // 选中点
                    if (_selectedLocation != null)
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: _selectedLocation!,
                            width: 40,
                            height: 40,
                            child: const Icon(
                              Icons.location_on,
                              color: Colors.red,
                              size: 32,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),

                // 搜索框
                Positioned(
                  top: 10,
                  left: 10,
                  right: 10,
                  child: Column(
                    children: [
                      TextField(
                        controller: _searchCtrl,
                        decoration: InputDecoration(
                          hintText: "搜索地点",
                          filled: true,
                          fillColor: Colors.white,
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.search),
                            onPressed: () => searchPlace(_searchCtrl.text),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onSubmitted: (v) => searchPlace(v),
                      ),
                      if (_searchResults.isNotEmpty)
                        Container(
                          color: Colors.white,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: _searchResults.map((e) {
                              final lat = double.parse(e['lat']);
                              final lon = double.parse(e['lon']);
                              return ListTile(
                                title: Text(e['name']),
                                subtitle: Text(e['address'] ?? ''),
                                onTap: () {
                                  _mapController.move(LatLng(lat, lon), 18);
                                  setState(() {
                                    _selectedLocation = LatLng(lat, lon);
                                    _searchResults.clear();
                                  });
                                },
                              );
                            }).toList(),
                          ),
                        ),
                    ],
                  ),
                ),

                // 控制面板
                Positioned(
                  top: 80,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: const [
                        BoxShadow(color: Colors.black12, blurRadius: 4),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "底图",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Row(
                          children: [
                            _baseBtn("矢量", "vec"),
                            const SizedBox(width: 4),
                            _baseBtn("卫星", "img"),
                            const SizedBox(width: 4),
                            _baseBtn("地形", "ter"),
                          ],
                        ),
                        const Divider(height: 8),
                        const Text(
                          "叠加图层",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        _layerSwitch(
                          "标注",
                          _showLabel,
                          (v) => setState(() => _showLabel = v),
                        ),
                        _layerSwitch(
                          "路网",
                          _showRoad,
                          (v) => setState(() => _showRoad = v),
                        ),
                        _layerSwitch(
                          "行政区",
                          _showDistrict,
                          (v) => setState(() => _showDistrict = v),
                        ),
                        _layerSwitch(
                          "3D建筑",
                          _show3DBuild,
                          (v) => setState(() => _show3DBuild = v),
                        ),
                        const Divider(height: 8),
                        const Text(
                          "绘制",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Wrap(
                          spacing: 4,
                          children: [
                            ElevatedButton(
                              onPressed: () =>
                                  setState(() => drawMode = "point"),
                              child: const Text("点"),
                            ),
                            ElevatedButton(
                              onPressed: () =>
                                  setState(() => drawMode = "polyline"),
                              child: const Text("线"),
                            ),
                            ElevatedButton(
                              onPressed: () =>
                                  setState(() => drawMode = "polygon"),
                              child: const Text("面"),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            ElevatedButton(
                              onPressed: finishDraw,
                              child: const Text("完成"),
                            ),
                            const SizedBox(width: 4),
                            ElevatedButton(
                              onPressed: clearDraw,
                              child: const Text("清空"),
                            ),
                          ],
                        ),
                        if (_distance != null)
                          Text("距离：${_distance!.toStringAsFixed(1)} m"),
                        if (_area != null)
                          Text("面积：${_area!.toStringAsFixed(1)} ㎡"),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _baseBtn(String txt, String type) {
    return GestureDetector(
      onTap: () => setState(() => _baseMapType = type),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        decoration: BoxDecoration(
          color: _baseMapType == type ? Colors.blue : Colors.white,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          txt,
          style: TextStyle(
            color: _baseMapType == type ? Colors.white : Colors.black87,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _layerSwitch(String txt, bool val, ValueChanged<bool> onChg) {
    return Row(
      children: [
        Text(txt, style: const TextStyle(fontSize: 12)),
        Switch(
          value: val,
          onChanged: onChg,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ],
    );
  }
}
