import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/api_models.dart';
import '../data/taskfit_api.dart';
import 'main_shell.dart';

class GoalSettingScreen extends StatefulWidget {
  const GoalSettingScreen({super.key});

  @override
  State<GoalSettingScreen> createState() => _GoalSettingScreenState();
}

class _GoalSettingScreenState extends State<GoalSettingScreen> {
  // 선택된 데이터 관리
  dynamic _selectedCompany; // {id, name}
  dynamic _selectedJobRole; // {id, name}
  bool _isGenerating = false;

  @override
  Widget build(BuildContext context) {
    final api = context.read<TaskFitApi>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('직무 목표 설정', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. 안내 배너
            _buildInfoBanner(),
            const SizedBox(height: 32),

            // 2. 희망 직무 섹션
            const Text('희망 직무', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildSectionCard(
              child: Column(
                children: [
                  _buildSentencePreview('직무', _selectedJobRole?['name']),
                  const SizedBox(height: 16),
                  // 직무 검색 자동완성
                  _buildJobAutocomplete(api),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // 3. 희망 회사 섹션
            const Text('희망 회사', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildSectionCard(
              child: Column(
                children: [
                  _buildSentencePreview('회사', _selectedCompany?['name']),
                  const SizedBox(height: 16),
                  // 회사 검색 자동완성
                  _buildCompanyAutocomplete(api),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // 4. 문제 생성 버튼
            _buildGenerateButton(api),
          ],
        ),
      ),
    );
  }

  // --- 위젯 빌더 함수들 ---

  Widget _buildInfoBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFFE8F0FF), borderRadius: BorderRadius.circular(12)),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lightbulb, color: Color(0xFF3B5BFF)),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              '회사를 검색하고 직무를 선택하면 AI가 실제 면접 및 실무 데이터를 기반으로 과제를 생성합니다.',
              style: TextStyle(fontSize: 13, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: child,
    );
  }

  Widget _buildSentencePreview(String type, String? value) {
    return Row(
      children: [
        Text('선택된 $type: '),
        Text(
          value ?? '미선택',
          style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  // 직무 검색 자동완성
  Widget _buildJobAutocomplete(TaskFitApi api) {
    return Autocomplete<Map<String, dynamic>>(
      displayStringForOption: (option) => option['name'] as String,
      optionsBuilder: (TextEditingValue textEditingValue) async {
        if (textEditingValue.text.isEmpty) return const Iterable.empty();
        // API 호출 결과가 List<dynamic>이므로 cast가 필요할 수 있습니다.
        final results = await api.searchJobRoles(null, textEditingValue.text);
        return results.cast<Map<String, dynamic>>();
      },
      onSelected: (selection) => setState(() => _selectedJobRole = selection),
      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
        return TextField(
          controller: controller,
          focusNode: focusNode,
          decoration: InputDecoration(
            hintText: '예: 백엔드 개발자, UI 디자인',
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      },
    );
  }

  // 회사 검색 자동완성
  Widget _buildCompanyAutocomplete(TaskFitApi api) {
    return Autocomplete<Map<String, dynamic>>(
      displayStringForOption: (option) => option['name'] as String,
      optionsBuilder: (TextEditingValue textEditingValue) async {
        if (textEditingValue.text.isEmpty) return const Iterable.empty();
        // API 호출 결과가 List<dynamic>이므로 cast가 필요할 수 있습니다.
        final results = await api.searchJobRoles(null, textEditingValue.text);
        return results.cast<Map<String, dynamic>>();
      },
      onSelected: (selection) => setState(() => _selectedCompany = selection),
      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
        return TextField(
          controller: controller,
          focusNode: focusNode,
          decoration: InputDecoration(
            hintText: '예: 토스, 네이버, 배달의민족',
            prefixIcon: const Icon(Icons.business),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      },
    );
  }

  Widget _buildGenerateButton(TaskFitApi api) {
    return ElevatedButton(
      onPressed: (_selectedCompany == null || _selectedJobRole == null || _isGenerating)
          ? null
          : () async {
        setState(() => _isGenerating = true);
        try {
          // 실제 선택된 ID를 전달합니다.
          await api.generateTasks(TaskGenerateRequest(
            company_id: _selectedCompany['id'],
            job_role_id: _selectedJobRole['id'],
            count: 3,
          ));

          if (mounted) {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainShell()));
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("과제 생성에 실패했습니다. 정보를 다시 확인해주세요.")),
          );
        } finally {
          setState(() => _isGenerating = false);
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF3B5BFF),
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: _isGenerating
          ? const CircularProgressIndicator(color: Colors.white)
          : const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [Icon(Icons.bolt), SizedBox(width: 8), Text('과제 생성하기')],
      ),
    );
  }
}