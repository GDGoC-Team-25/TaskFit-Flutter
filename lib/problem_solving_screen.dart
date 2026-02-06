import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'boss_chat_screen.dart';
import 'main.dart';

class ProblemSolvingScreen extends StatelessWidget {
  const ProblemSolvingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          children: [
            Text('문제 풀이', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text('삼성전자 · 소프트웨어 엔지니어', style: TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: const Color(0xFFE8F0FF), borderRadius: BorderRadius.circular(4)),
                        child: const Text('#기술면접', style: TextStyle(color: Color(0xFF3B5BFF), fontSize: 12)),
                      ),
                      const Text('15분 예상', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text('동기화와 교착 상태에 대해 설명해주세요.', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 24),
                  const Text('문제', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                    child: const Text(
                      '멀티스레드 환경에서 동기화는 왜 필요한지 설명하고, 교착 상태(Deadlock)가 발생하는 조건 네 가지를 모두 서술한 후, 실제 데이터베이스 시스템이나 파일 시스템에서 교착 상태를 해결하기 위해 사용되는 방법 한 가지를 예시로 들어 설명해주세요.',
                      style: TextStyle(height: 1.6),
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('답변 작성', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text('00:23:15', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    maxLines: 10,
                    decoration: InputDecoration(
                      hintText: '여기에 답변을 작성해주세요. 키워드 중심으로 구조적으로 작성하는 것을 추천합니다.',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                    child: const Text('저장'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BossChatScreen())),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F172A),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('제출하기'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}