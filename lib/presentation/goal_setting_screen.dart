import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/api_models.dart';
import '../data/taskfit_api.dart';
import '../task_view_model.dart';
import 'main_shell.dart';

class GoalSettingScreen extends StatefulWidget {
  const GoalSettingScreen({super.key});

  @override
  State<GoalSettingScreen> createState() => _GoalSettingScreenState();
}

class _GoalSettingScreenState extends State<GoalSettingScreen> {
  // 회사 관련
  List<Map<String, dynamic>> _companies = [];
  Map<String, dynamic>? _selectedCompany;
  final TextEditingController _companySearchController = TextEditingController();
  bool _isLoadingCompanies = false;

  // 직무 관련
  List<String> _categories = [];
  String? _selectedCategory;
  List<Map<String, dynamic>> _jobRoles = [];
  Map<String, dynamic>? _selectedJobRole;
  bool _isLoadingCategories = false;
  bool _isLoadingJobRoles = false;

  bool _isGenerating = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCategories();
      _loadCompanies(null);
    });
  }

  @override
  void dispose() {
    _companySearchController.dispose();
    super.dispose();
  }

  // 직무 카테고리 목록 로드
  Future<void> _loadCategories() async {
    final api = context.read<TaskFitApi>();
    setState(() => _isLoadingCategories = true);
    try {
      final result = await api.getJobCategories();
      if (result is List) {
        setState(() {
          _categories = result.cast<String>();
        });
      }
    } catch (_) {}
    setState(() => _isLoadingCategories = false);
  }

  // 카테고리 선택 시 해당 직무 목록 로드
  Future<void> _loadJobRoles(String category) async {
    final api = context.read<TaskFitApi>();
    setState(() {
      _isLoadingJobRoles = true;
      _selectedJobRole = null;
      _jobRoles = [];
    });
    try {
      final result = await api.searchJobRoles(category, null);
      if (result is List) {
        setState(() {
          _jobRoles = result.cast<Map<String, dynamic>>();
        });
      }
    } catch (_) {}
    setState(() => _isLoadingJobRoles = false);
  }

  // 회사 검색
  Future<void> _loadCompanies(String? query) async {
    final api = context.read<TaskFitApi>();
    setState(() => _isLoadingCompanies = true);
    try {
      final result = await api.searchCompanies(query, 20);
      if (result is List) {
        setState(() {
          _companies = result.cast<Map<String, dynamic>>();
        });
      }
    } catch (_) {}
    setState(() => _isLoadingCompanies = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('직무 목표 설정', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoBanner(),
            const SizedBox(height: 32),

            // 1. 희망 회사 섹션
            const Text('희망 회사', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildSectionCard(
              child: _buildCompanySelector(),
            ),
            const SizedBox(height: 32),

            // 2. 희망 직무 섹션
            const Text('희망 직무', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildSectionCard(
              child: _buildJobRoleSelector(),
            ),
            const SizedBox(height: 40),

            // 3. 문제 생성 버튼
            _buildGenerateButton(),
          ],
        ),
      ),
    );
  }

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
              '회사와 직무를 선택하면 AI가 실제 면접 및 실무 데이터를 기반으로 과제를 생성합니다.',
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

  // --- 회사 선택 ---
  Widget _buildCompanySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 검색 입력
        TextField(
          controller: _companySearchController,
          decoration: InputDecoration(
            hintText: '회사 이름 검색',
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          onChanged: (value) {
            _loadCompanies(value.isEmpty ? null : value);
          },
        ),
        const SizedBox(height: 12),

        // 회사 목록 드롭다운
        if (_isLoadingCompanies)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))),
          )
        else if (_companies.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text('검색 결과가 없습니다.', style: TextStyle(color: Colors.grey, fontSize: 13)),
          )
        else
          Container(
            constraints: const BoxConstraints(maxHeight: 200),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade200),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: _companies.length,
              separatorBuilder: (_, __) => Divider(height: 1, color: Colors.grey.shade100),
              itemBuilder: (context, index) {
                final company = _companies[index];
                final isSelected = _selectedCompany?['id'] == company['id'];
                return ListTile(
                  dense: true,
                  selected: isSelected,
                  selectedTileColor: const Color(0xFFE8F0FF),
                  leading: company['logo_url'] != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: Image.network(company['logo_url'], width: 28, height: 28, fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(Icons.business, size: 28, color: Colors.grey)),
                        )
                      : const Icon(Icons.business, size: 28, color: Colors.grey),
                  title: Text(
                    company['name'] ?? '',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? const Color(0xFF3B5BFF) : Colors.black87,
                    ),
                  ),
                  trailing: isSelected ? const Icon(Icons.check_circle, color: Color(0xFF3B5BFF), size: 20) : null,
                  onTap: () {
                    setState(() => _selectedCompany = company);
                  },
                );
              },
            ),
          ),

        // 선택된 회사 표시
        if (_selectedCompany != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F0FF),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle, color: Color(0xFF3B5BFF), size: 16),
                const SizedBox(width: 6),
                Text(
                  _selectedCompany!['name'],
                  style: const TextStyle(color: Color(0xFF3B5BFF), fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const SizedBox(width: 4),
                GestureDetector(
                  onTap: () => setState(() => _selectedCompany = null),
                  child: const Icon(Icons.close, color: Color(0xFF3B5BFF), size: 16),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  // --- 직무 선택 (카테고리 → 직무 2단계) ---
  Widget _buildJobRoleSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1단계: 카테고리 드롭다운
        const Text('카테고리', style: TextStyle(fontSize: 13, color: Colors.grey)),
        const SizedBox(height: 8),
        if (_isLoadingCategories)
          const Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)))
        else
          DropdownButtonFormField<String>(
            value: _selectedCategory,
            isExpanded: true,
            decoration: InputDecoration(
              hintText: '카테고리를 선택하세요',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            items: _categories.map((category) {
              return DropdownMenuItem(value: category, child: Text(category));
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() => _selectedCategory = value);
                _loadJobRoles(value);
              }
            },
          ),

        const SizedBox(height: 16),

        // 2단계: 직무 드롭다운
        const Text('직무', style: TextStyle(fontSize: 13, color: Colors.grey)),
        const SizedBox(height: 8),
        if (_isLoadingJobRoles)
          const Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)))
        else
          DropdownButtonFormField<int>(
            value: _selectedJobRole?['id'] as int?,
            isExpanded: true,
            decoration: InputDecoration(
              hintText: _selectedCategory == null ? '카테고리를 먼저 선택하세요' : '직무를 선택하세요',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            items: _jobRoles.map((role) {
              return DropdownMenuItem<int>(
                value: role['id'] as int,
                child: Text(role['name'] ?? ''),
              );
            }).toList(),
            onChanged: _selectedCategory == null
                ? null
                : (value) {
                    if (value != null) {
                      final role = _jobRoles.firstWhere((r) => r['id'] == value);
                      setState(() => _selectedJobRole = role);
                    }
                  },
          ),

        // 선택된 직무 표시
        if (_selectedJobRole != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F0FF),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.work, color: Color(0xFF3B5BFF), size: 16),
                const SizedBox(width: 6),
                Text(
                  '${_selectedCategory} > ${_selectedJobRole!['name']}',
                  style: const TextStyle(color: Color(0xFF3B5BFF), fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildGenerateButton() {
    final api = context.read<TaskFitApi>();
    final canGenerate = _selectedCompany != null && _selectedJobRole != null && !_isGenerating;

    return ElevatedButton(
      onPressed: canGenerate
          ? () async {
              setState(() => _isGenerating = true);
              try {
                await api.generateTasks(TaskGenerateRequest(
                  company_id: _selectedCompany!['id'],
                  job_role_id: _selectedJobRole!['id'],
                  count: 3,
                ));

                if (mounted) {
                  context.read<TaskViewModel>().setGoal(
                    companyName: _selectedCompany!['name'],
                    jobRoleName: _selectedJobRole!['name'],
                  );
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainShell()));
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("과제 생성에 실패했습니다. 정보를 다시 확인해주세요.")),
                  );
                }
              } finally {
                if (mounted) setState(() => _isGenerating = false);
              }
            }
          : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF3B5BFF),
        foregroundColor: Colors.white,
        disabledBackgroundColor: Colors.grey.shade300,
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: _isGenerating
          ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
          : const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [Icon(Icons.bolt), SizedBox(width: 8), Text('과제 생성하기')],
            ),
    );
  }
}
