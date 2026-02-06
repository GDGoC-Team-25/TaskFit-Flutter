import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import '../data/taskfit_api.dart';
import '../task_view_model.dart';
import 'problem_solving_screen.dart';
import 'goal_setting_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // 화면 진입 시 초기 데이터 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TaskViewModel>().fetchTasks();
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<TaskViewModel>();

    return Scaffold(
      appBar: AppBar(
        leadingWidth: 100,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: SvgPicture.asset('assets/logo.svg', fit: BoxFit.contain),
        ),
        centerTitle: true,
        title: const Text(
          'TASK FIT',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => viewModel.fetchTasks(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. 현재 설정된 목표 표시 (첫 번째 과제 정보 기반 혹은 프로필 정보 기반)
              _buildTargetChip(viewModel.tasks.isNotEmpty ? viewModel.tasks.first : null),

              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '생성된 문제 목록',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const GoalSettingScreen()));
                    },
                    icon: const Icon(Icons.refresh, size: 16),
                    label: const Text('새로 생성'),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 2. 과제 목록 영역
              Expanded(
                child: viewModel.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : viewModel.tasks.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                  itemCount: viewModel.tasks.length,
                  itemBuilder: (context, index) {
                    final task = viewModel.tasks[index];
                    return _buildProblemCard(context, task);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTargetChip(dynamic task) {
    String label = '목표를 설정해주세요';
    if (task != null) {
      label = '${task['company_name'] ?? '회사'} > ${task['job_role_name'] ?? '직무'}';
    }
    return Chip(
      avatar: const Icon(Icons.business, size: 16, color: Color(0xFF3B5BFF)),
      label: Text(label),
      backgroundColor: const Color(0xFFE8F0FF),
      side: BorderSide.none,
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('생성된 문제가 없습니다.', style: TextStyle(color: Colors.grey)),
          Text('우측 상단의 "새로 생성"을 눌러보세요.', style: TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildProblemCard(BuildContext context, dynamic task) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    task['category'] ?? '직무',
                    style: const TextStyle(color: Colors.green, fontSize: 12),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '난이도: ${task['difficulty'] ?? '중'}',
                    style: const TextStyle(color: Colors.orange, fontSize: 12),
                  ),
                ),
                const Spacer(),
                Text(
                  task['created_at']?.toString().split('T')[0] ?? '2025.03',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              task['title'] ?? '제목이 없습니다.',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                const Icon(Icons.timer_outlined, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                const Text(
                  '15분 예상', // 필요 시 서버 데이터 연결
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
                const SizedBox(width: 12),
                const Icon(Icons.edit_note, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                const Text(
                  '서술형',
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProblemSolvingScreen(taskId: task['id']),
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B5BFF),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text('풀러가기'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}