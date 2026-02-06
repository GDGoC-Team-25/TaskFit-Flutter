import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/api_models.dart';
import '../data/taskfit_api.dart';
import 'boss_chat_screen.dart';

class ProblemSolvingScreen extends StatefulWidget {
  final int taskId; // HomeScreen에서 넘겨받은 ID

  const ProblemSolvingScreen({super.key, required this.taskId});

  @override
  State<ProblemSolvingScreen> createState() => _ProblemSolvingScreenState();
}

class _ProblemSolvingScreenState extends State<ProblemSolvingScreen> {
  final TextEditingController _answerController = TextEditingController();
  late Future<Map<String, dynamic>> _taskDetailFuture;
  bool _isSubmitting = false;

  @override
  Future<void> initState() async {
    super.initState();
    // 1. 화면 진입 시 해당 과제의 상세 지문을 불러옵니다.
    _taskDetailFuture = await context.read<TaskFitApi>().getTaskDetail(widget.taskId);
  }

  // 제출 로직
  Future<void> _submitAnswer() async {
    final content = _answerController.text.trim();
    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('답변을 입력해주세요.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    final api = context.read<TaskFitApi>();

    try {
      // 2. 서버에 답변 제출 (is_draft: false로 보내면 AI 스레드가 생성됩니다)
      final response = await api.createSubmission(
        SubmissionCreateRequest(
          task_id: widget.taskId,
          content: content,
          is_draft: false,
        ),
      );

      // 3. 제출 성공 시 서버에서 받은 thread_id를 가지고 채팅방으로 이동
      final int? threadId = response['thread_id'];
      if (threadId != null && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => BossChatScreen(threadId: threadId),
          ),
        );
      }
    } catch (e) {
      print("제출 실패: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('제출에 실패했습니다. 다시 시도해주세요.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: FutureBuilder<Map<String, dynamic>>(
          future: _taskDetailFuture,
          builder: (context, snapshot) {
            final data = snapshot.data;
            return Column(
              children: [
                const Text('문제 풀이', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text(
                  data != null ? '${data['company_name']} · ${data['job_role_name']}' : '로딩 중...',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            );
          },
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _taskDetailFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('문제를 불러오지 못했습니다.'));
          }

          final task = snapshot.data!;

          return Column(
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
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F0FF),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '#${task['category'] ?? '기술면접'}',
                              style: const TextStyle(color: Color(0xFF3B5BFF), fontSize: 12),
                            ),
                          ),
                          const Text('15분 예상', style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        task['title'] ?? '',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 24),
                      const Text('문제', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          task['description'] ?? '',
                          style: const TextStyle(height: 1.6),
                        ),
                      ),
                      const SizedBox(height: 32),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('답변 작성', style: TextStyle(fontWeight: FontWeight.bold)),
                          Text('실시간 저장 중', style: TextStyle(color: Colors.grey, fontSize: 12)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _answerController,
                        maxLines: 10,
                        decoration: InputDecoration(
                          hintText: '여기에 답변을 작성해주세요. 키워드 중심으로 구조적으로 작성하는 것을 추천합니다.',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
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
                        onPressed: () {
                          // 임시 저장 로직 (필요 시 is_draft: true로 API 호출 가능)
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('저장'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _submitAnswer,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0F172A),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: _isSubmitting
                            ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                            : const Text('제출하기'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}