import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('상사와의 채팅 목록', style: TextStyle(fontWeight: FontWeight.bold))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildChatListItem('김팀장 (개발팀)', '시스템 설계', '이번 분산 캐시 전략안 검토 부탁합니다. Redis Cluster 도입 시 예상 장애 포인트와...'),
          _buildChatListItem('이상무 (기획팀)', '요구사항 협의', '고객의 긴급한 기능 추가 요청이 들어왔습니다. 기존 일정과 팀 리소스를 고려하여...'),
          _buildChatListItem('박이사 (경영지원)', '성과 평가', '1분기 성과에 대해 간략히 보고드리겠습니다. 주요 성과 3가지를 구체적인 지표와 함께...'),
        ],
      ),
    );
  }

  Widget _buildChatListItem(String name, String tag, String msg) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(radius: 14),
                const SizedBox(width: 8),
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: Colors.purple.shade50, borderRadius: BorderRadius.circular(4)),
                  child: Text(tag, style: TextStyle(color: Colors.purple.shade400, fontSize: 10)),
                ),
                const Spacer(),
                const Text('2025.03.18', style: TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 12),
            Text(msg, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, color: Colors.black54)),
            const SizedBox(height: 12),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('대화 24건', style: TextStyle(fontSize: 12, color: Colors.grey)),
                Text('대화 보기 >', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
