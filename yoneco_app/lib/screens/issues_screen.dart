import 'package:flutter/material.dart';
import '../services/language_service.dart';
import '../services/api_service.dart';

class IssuesScreen extends StatefulWidget {
  const IssuesScreen({super.key});

  @override
  State<IssuesScreen> createState() => _IssuesScreenState();
}

class _IssuesScreenState extends State<IssuesScreen> {
  final LanguageService _languageService = LanguageService();
  final ApiService _apiService = ApiService();
  List<Map<String, dynamic>> _issues = [];
  bool _isLoading = true;
  bool _isGridView = false;

  @override
  void initState() {
    super.initState();
    _languageService.addListener(_onLanguageChanged);
    _loadIssues();
  }

  Future<void> _loadIssues() async {
    try {
      print('Attempting to load issues from API...');
      final issues = await _apiService.getIssues();
      print('API returned ${issues.length} issues');
      
      if (mounted) {
        setState(() {
          // Filter only active issues, fallback to all if no active field
          var activeIssues = issues.where((issue) => issue['is_active'] != false).toList();
          
          // Sort issues to put "Other" last
          activeIssues.sort((a, b) {
            final aNameEn = (a['name_en'] ?? '').toLowerCase();
            final aNameNy = (a['name_ny'] ?? '').toLowerCase();
            final bNameEn = (b['name_en'] ?? '').toLowerCase();
            final bNameNy = (b['name_ny'] ?? '').toLowerCase();
            
            // Check if 'a' is "other"
            bool aIsOther = aNameEn == 'other' || aNameNy == 'zina' || aNameEn.contains('other');
            // Check if 'b' is "other"
            bool bIsOther = bNameEn == 'other' || bNameNy == 'zina' || bNameEn.contains('other');
            
            if (aIsOther && !bIsOther) return 1;  // a comes after b
            if (!aIsOther && bIsOther) return -1; // a comes before b
            return 0; // maintain original order
          });
          
          _issues = activeIssues;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading issues from API: $e');
      // Always fallback to predefined issues if API fails
      if (mounted) {
        setState(() {
          var predefinedIssues = _getPredefinedIssues();
          
          // Sort predefined issues to put "Other" last
          predefinedIssues.sort((a, b) {
            final aNameEn = (a['name_en'] ?? '').toLowerCase();
            final aNameNy = (a['name_ny'] ?? '').toLowerCase();
            final bNameEn = (b['name_en'] ?? '').toLowerCase();
            final bNameNy = (b['name_ny'] ?? '').toLowerCase();
            
            bool aIsOther = aNameEn == 'other' || aNameNy == 'zina' || aNameEn.contains('other');
            bool bIsOther = bNameEn == 'other' || bNameNy == 'zina' || bNameEn.contains('other');
            
            if (aIsOther && !bIsOther) return 1;
            if (!aIsOther && bIsOther) return -1;
            return 0;
          });
          
          _issues = predefinedIssues;
          _isLoading = false;
        });
      }
    }
  }

  List<Map<String, dynamic>> _getPredefinedIssues() {
    return [
      {'name_en': 'Depression', 'name_ny': 'Kukhumudwa', 'emoji': '😔'},
      {'name_en': 'Stress', 'name_ny': 'Kupsinjika', 'emoji': '😤'},
      {'name_en': 'Grief and Loss', 'name_ny': 'Chisoni ndi Kutaya', 'emoji': '😢'},
      {'name_en': 'Trauma and PTSD', 'name_ny': 'Zowawa Zamtima', 'emoji': '💔'},
      {'name_en': 'Substance Abuse', 'name_ny': 'Zolakalaka', 'emoji': '🚫'},
      {'name_en': 'Relationship Issues', 'name_ny': 'Mavuto Aubwenzi', 'emoji': '💕'},
      {'name_en': 'Self Harm', 'name_ny': 'Kudzivulaza', 'emoji': '🩹'},
      {'name_en': 'Low Self Esteem', 'name_ny': 'Kudzinyoza', 'emoji': '😞'},
      {'name_en': 'Suicidal', 'name_ny': 'Kudzipha', 'emoji': '🆘'},
      {'name_en': 'Family Problems', 'name_ny': 'Mavuto Abanja', 'emoji': '👨👩👧👦'},
      {'name_en': 'Eating Disorder', 'name_ny': 'Mavuto Akudya', 'emoji': '🍽️'},
      {'name_en': 'Sleep Problems/Insomnia', 'name_ny': 'Mavuto Agono', 'emoji': '😴'},
      {'name_en': 'Work Stress', 'name_ny': 'Kupsinjika Pantchito', 'emoji': '💼'},
      {'name_en': 'Academic Stress', 'name_ny': 'Kupsinjika Pasukulu', 'emoji': '📚'},
      {'name_en': 'Other', 'name_ny': 'Zina', 'emoji': '❓'},
    ];
  }

  @override
  void dispose() {
    _languageService.removeListener(_onLanguageChanged);
    super.dispose();
  }

  void _onLanguageChanged() {
    if (mounted) setState(() {});
  }

  IconData _getIconForIssue(String issueName) {
    final name = issueName.toLowerCase();
    if (name.contains('suicide') || name.contains('kudzipha')) return Icons.sos;
    if (name.contains('depress') || name.contains('kukhumudwa')) return Icons.sentiment_dissatisfied;
    if (name.contains('anxiety') || name.contains('nkhawa')) return Icons.mood_bad;
    if (name.contains('stress') || name.contains('kupsinjika')) return Icons.bolt;
    if (name.contains('trauma') || name.contains('ptsd')) return Icons.healing;
    if (name.contains('relationship') || name.contains('ubwenzi')) return Icons.favorite_border;
    if (name.contains('family') || name.contains('banja')) return Icons.family_restroom;
    if (name.contains('substance') || name.contains('addiction') || name.contains('zolakalaka')) return Icons.block;
    if (name.contains('grief') || name.contains('chisoni')) return Icons.heart_broken;
    if (name.contains('self-harm') || name.contains('kudzivulaza')) return Icons.warning;
    if (name.contains('eating') || name.contains('akudya')) return Icons.restaurant;
    if (name.contains('sleep') || name.contains('agono')) return Icons.bedtime;
    if (name.contains('work') || name.contains('ntchito')) return Icons.work;
    if (name.contains('academic') || name.contains('sukulu')) return Icons.school;
    if (name.contains('social') || name.contains('anthu')) return Icons.people;
    return Icons.help_outline;
  }

  String _getEmojiForIssue(String issueName) {
    final name = issueName.toLowerCase();
    if (name.contains('other') || name.contains('zina')) return '❓';
    if (name.contains('suicide') || name.contains('kudzipha')) return '🆘';
    if (name.contains('depress') || name.contains('kukhumudwa')) return '😔';
    if (name.contains('anxiety') || name.contains('nkhawa')) return '😰';
    if (name.contains('stress') || name.contains('kupsinjika')) return '😤';
    if (name.contains('trauma') || name.contains('ptsd')) return '💔';
    if (name.contains('relationship') || name.contains('ubwenzi')) return '💕';
    if (name.contains('family') || name.contains('banja')) return '👨👩👧👦';
    if (name.contains('substance') || name.contains('addiction') || name.contains('zolakalaka')) return '🚫';
    if (name.contains('grief') || name.contains('chisoni')) return '😢';
    if (name.contains('self-harm') || name.contains('kudzivulaza')) return '🩹';
    if (name.contains('eating') || name.contains('akudya')) return '🍽️';
    if (name.contains('sleep') || name.contains('agono') || name.contains('insomnia')) return '😴';
    if (name.contains('work') || name.contains('ntchito')) return '💼';
    if (name.contains('academic') || name.contains('sukulu')) return '📚';
    if (name.contains('esteem') || name.contains('kudzinyoza')) return '😞';
    return '😔'; // Default emoji
  }

  Color _getColorForIssue(String issueName) {
    final name = issueName.toLowerCase();
    if (name.contains('suicide') || name.contains('kudzipha')) return Colors.red;
    if (name.contains('depress') || name.contains('kukhumudwa')) return Colors.indigo;
    if (name.contains('anxiety') || name.contains('nkhawa')) return Colors.orange;
    if (name.contains('stress') || name.contains('kupsinjika')) return Colors.amber;
    if (name.contains('trauma') || name.contains('ptsd')) return Colors.purple;
    if (name.contains('relationship') || name.contains('ubwenzi')) return Colors.pink;
    if (name.contains('family') || name.contains('banja')) return Colors.green;
    if (name.contains('substance') || name.contains('zolakalaka')) return Colors.deepOrange;
    if (name.contains('grief') || name.contains('chisoni')) return Colors.blueGrey;
    if (name.contains('self-harm') || name.contains('kudzivulaza')) return Colors.red;
    if (name.contains('eating') || name.contains('akudya')) return Colors.teal;
    if (name.contains('sleep') || name.contains('agono')) return Colors.deepPurple;
    if (name.contains('work') || name.contains('ntchito')) return Colors.brown;
    if (name.contains('academic') || name.contains('sukulu')) return Colors.blue;
    if (name.contains('social') || name.contains('anthu')) return Colors.cyan;
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    final currentLanguage = _languageService.currentLanguage;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(_languageService.translate('issues_title')),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _isLoading = true;
              });
              _loadIssues();
            },
            tooltip: 'Refresh Issues',
          ),
          IconButton(
            icon: Icon(_isGridView ? Icons.list : Icons.grid_view),
            onPressed: () {
              setState(() {
                _isGridView = !_isGridView;
              });
            },
            tooltip: _isGridView ? 'List View' : 'Grid View',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      _languageService.translate('issues_subtitle'),
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: _isGridView ? _buildGridView() : _buildListView(),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridView() {
    final currentLanguage = _languageService.currentLanguage;
    
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16.0,
        mainAxisSpacing: 16.0,
        childAspectRatio: 1.0,
      ),
      itemCount: _issues.length,
      itemBuilder: (context, index) {
        final issue = _issues[index];
        final issueName = currentLanguage == 'ny' 
            ? (issue['name_ny'] ?? issue['name_en'])
            : issue['name_en'];
        final issueColor = _getColorForIssue(issueName);
        
        return GestureDetector(
          onTap: () {
            Navigator.pushNamed(
              context,
              '/counsellor',
              arguments: issueName,
            );
          },
          child: Card(
            elevation: 6,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    issueColor.withOpacity(0.1),
                    issueColor.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(16.0),
                border: Border.all(
                  color: issueColor.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _getIconForIssue(issueName),
                    size: 48,
                    color: issueColor,
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      issueName,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color.lerp(issueColor, Colors.black, 0.3)!,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildListView() {
    final currentLanguage = _languageService.currentLanguage;
    
    return ListView.builder(
      itemCount: _issues.length,
      itemBuilder: (context, index) {
        final issue = _issues[index];
        final issueName = currentLanguage == 'ny' 
            ? (issue['name_ny'] ?? issue['name_en'])
            : issue['name_en'];
        // Get emoji based on issue name, same as grid view
        final emoji = _getEmojiForIssue(issueName);
        final issueColor = _getColorForIssue(issueName);
        
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 6.0),
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 8.0,
            ),
            leading: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: issueColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: issueColor.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Center(
                child: Text(
                  emoji,
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            ),
            title: Text(
              issueName,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color.lerp(issueColor, Colors.black, 0.3)!,
              ),
            ),
            subtitle: Text(
              _languageService.translate('tap_to_get_help'),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
            trailing: Icon(
              Icons.arrow_forward_ios,
              color: issueColor,
              size: 16,
            ),
            onTap: () {
              Navigator.pushNamed(
                context,
                '/counsellor',
                arguments: issueName,
              );
            },
          ),
        );
      },
    );
  }
}