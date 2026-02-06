import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/api_models.dart';
import '../data/taskfit_api.dart';
import 'boss_chat_screen.dart';

class ProblemSolvingScreen extends StatefulWidget {
  final int taskId;

  const ProblemSolvingScreen({super.key, required this.taskId});

  @override
  State<ProblemSolvingScreen> createState() => _ProblemSolvingScreenState();
}

class _ProblemSolvingScreenState extends State<ProblemSolvingScreen> {
  final TextEditingController _answerController = TextEditingController();
  Future<dynamic>? _taskDetailFuture;
  bool _isSubmitting = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // initState에서는 async 사용 불가 - addPostFrameCallback으로 처리
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTaskDetail();
    });
  }

  void _loadTaskDetail() {
    final api = context.read<TaskFitApi>();
    setState(() {
      // 백엔드 TaskDetailResponse:
      // { id, title, description, category, difficulty, estimated_minutes,
      //   answer_type, tech_stack, company: {id, name}, job_role: {id, name},
      //   created_at, my_submission: {id, status, is_draft} | null }
      _taskDetailFuture = api.getTaskDetail(widget.taskId);
    });
  }

  // 임시 저장
  Future<void> _saveDraft() async {
    final content = _answerController.text.trim();
    if (content.isEmpty) return;

    setState(() => _isSaving = true);
    final api = context.read<TaskFitApi>();

    try {
      await api.createSubmission(
        SubmissionCreateRequest(
          task_id: widget.taskId,
          content: content,
          is_draft: true,
        ),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('임시 저장되었습니다.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('저장에 실패했습니다.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
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
      // 백엔드 SubmissionCreateResponse:
      // { submission: {...}, thread: {id, persona_name, ...} | null, first_message: {...} | null }
      final response = await api.createSubmission(
        SubmissionCreateRequest(
          task_id: widget.taskId,
          content: content,
          is_draft: false,
        ),
      );

      final threadData = response?['thread'];
      final int? threadId = threadData?['id'];

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
        title: FutureBuilder<dynamic>(
          future: _taskDetailFuture,
          builder: (context, snapshot) {
            final data = snapshot.data;
            return Column(
              children: [
                const Text('문제 풀이', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text(
                  data != null
                      ? '${data['company']?['name'] ?? ''} · ${data['job_role']?['name'] ?? ''}'
                      : '로딩 중...',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            );
          },
        ),
      ),
      body: FutureBuilder<dynamic>(
        future: _taskDetailFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || snapshot.data == null) {
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
                              '#${task['category'] ?? ''}',
                              style: const TextStyle(color: Color(0xFF3B5BFF), fontSize: 12),
                            ),
                          ),
                          Text('${task['estimated_minutes'] ?? 15}분 예상', style: const TextStyle(color: Colors.grey)),
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
                        onPressed: _isSaving ? null : _saveDraft,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: _isSaving
                            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                            : const Text('저장'),
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
