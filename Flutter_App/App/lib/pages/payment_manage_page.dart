import 'package:flutter/material.dart';

class PaymentManagePage extends StatelessWidget {
  const PaymentManagePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('支付管理'),
        elevation: 1,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildPaymentItem('微信支付', Icons.wechat, '已绑定 · ****8888'),
          _buildPaymentItem('支付宝', Icons.account_balance_wallet, '未绑定'),
          _buildPaymentItem('银行卡', Icons.credit_card, '已绑定 · ****1234'),
          const SizedBox(height: 24),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.lock, color: Colors.orange),
            title: const Text('支付密码'),
            trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('暂未实现支付密码修改功能')),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.history, color: Colors.blue),
            title: const Text('支付记录'),
            trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('暂未实现支付记录查询功能')),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentItem(String title, IconData icon, String desc) {
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
          Icon(icon, size: 28, color: Colors.green),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                Text(desc, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              // 绑定/解绑逻辑
            },
            child: const Text('管理'),
          ),
        ],
      ),
    );
  }
}