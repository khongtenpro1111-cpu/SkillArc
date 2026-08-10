import 'package:flutter/material.dart';
import 'package:skill_arc/core/constants/app_strings.dart';
import 'package:skill_arc/core/constants/design_tokens.dart';
import 'article_detail_screen.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'All'; // Will map to localized 'all'

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  final List<Map<String, dynamic>> _articles = [
    {
      'title': 'Lập trình Hướng đối tượng OOP chuyên sâu với Java & C#',
      'category': 'Programming',
      'author': 'Admin',
      'readTime': '10 min',
      'isTrending': true,
      'content': 'Lập trình hướng đối tượng (OOP) là nền tảng cốt lõi của hầu hết các ngôn ngữ lập trình hiện đại như Java và C#.\n\n'
          '1. Các nguyên lý cơ bản của OOP:\n'
          '• Đóng gói (Encapsulation): Che giấu thông tin chi tiết và bảo vệ dữ liệu bên trong đối tượng thông qua private fields và public getters/setters.\n'
          '• Kế thừa (Inheritance): Tái sử dụng mã nguồn bằng cách cho phép lớp con kế thừa thuộc tính và phương thức từ lớp cha.\n'
          '• Đa hình (Polymorphism): Cho phép một phương thức hành xử khác nhau dựa trên đối tượng gọi nó. Ví dụ: nạp chồng (overloading) và ghi đè (overriding).\n'
          '• Trừu tượng (Abstraction): Tập trung vào giao diện bên ngoài của đối tượng thay vì chi tiết triển khai nội bộ thông qua Interface và Abstract Class.\n\n'
          '2. Điểm khác biệt giữa Java và C#:\n'
          'Mặc dù cả hai đều là ngôn ngữ OOP mạnh mẽ, Java quản lý bộ nhớ hoàn toàn bằng Garbage Collector tự động và chạy trên JVM, trong khi C# chạy trên CLR (.NET Framework) và hỗ trợ các tính năng hiện đại như Properties trực tiếp, LINQ, và con trỏ không an toàn (unsafe code) khi cần thiết.',
    },
    {
      'title': 'Tối ưu hiệu năng ứng dụng Flutter với RepaintBoundary',
      'category': 'Mobile',
      'author': 'Minh Tran',
      'readTime': '7 min',
      'isTrending': true,
      'content': 'Trong Flutter, việc tối ưu hóa render (hiệu năng giao diện) là cực kỳ quan trọng để đạt 60fps hoặc 120fps mượt mà.\n\n'
          '1. RepaintBoundary là gì?\n'
          'Mỗi khi một Widget được vẽ lại (repaint), Flutter sẽ đi qua toàn bộ Widget cây để repaint. RepaintBoundary tạo ra một layer vẽ riêng biệt, cô lập việc vẽ lại của một Widget con khỏi phần còn lại của màn hình.\n\n'
          '2. Khi nào nên sử dụng?\n'
          '• Sử dụng cho các Widget chuyển động liên tục (như hoạt ảnh xoay tròn, hiệu ứng nhấp nháy, Canvas vẽ tự do).\n'
          '• Sử dụng cho các phần giao diện tĩnh cực kỳ phức tạp nhưng nằm cạnh một phần giao diện động.\n\n'
          '3. Lưu ý:\n'
          'Không lạm dụng RepaintBoundary cho mọi Widget vì việc tạo ra quá nhiều Layer vẽ riêng biệt sẽ ngốn dung lượng bộ nhớ GPU.',
    },
    {
      'title': 'Cấu hình định tuyến động OSPF trên giả lập Cisco GNS3',
      'category': 'Networking',
      'author': 'Hoang Nguyen',
      'readTime': '12 min',
      'isTrending': true,
      'content': 'Giao thức OSPF (Open Shortest Path First) là giao thức định tuyến động dạng Link-State được sử dụng rộng rãi nhất trong mạng doanh nghiệp hiện nay.\n\n'
          '1. Các bước triển khai cơ bản trên Router Cisco:\n'
          '• Bước 1: Kích hoạt tiến trình OSPF bằng lệnh `router ospf <process-id>`.\n'
          '• Bước 2: Thiết lập router ID định danh duy nhất.\n'
          '• Bước 3: Quảng bá mạng trực tiếp thông qua lệnh `network <ip-address> <wildcard-mask> area <area-id>`.\n\n'
          '2. Tại sao lại chia Area?\n'
          'OSPF chia mạng thành các Area (vùng) để giảm dung lượng bảng cơ sở dữ liệu trạng thái đường truyền (LSDB) trên mỗi router. Vùng trung tâm bắt buộc phải là Area 0 (Backbone Area).',
    },
    {
      'title': 'Tích hợp Hive database & RESTful API trong ứng dụng Flutter',
      'category': 'Database',
      'author': 'Thanh Pham',
      'readTime': '8 min',
      'isTrending': false,
      'content': 'Để xây dựng một ứng dụng Mobile chất lượng, chiến lược kết hợp Offline-First bằng cách lưu trữ cục bộ (Hive) và đồng bộ qua API (RESTful API) là lựa chọn tối ưu.\n\n'
          '1. Tại sao dùng Hive?\n'
          'Hive là cơ sở dữ liệu key-value được viết hoàn toàn bằng Dart, tốc độ cực nhanh và hoạt động mượt mà trên thiết bị di động mà không cần file binary SQLite cồng kềnh.\n\n'
          '2. Cách đồng bộ dữ liệu:\n'
          '• Bước 1: Gọi API qua HTTP để nhận dữ liệu JSON mới nhất từ Backend (Spring Boot/Node.js).\n'
          '• Bước 2: Lưu trực tiếp dữ liệu đó vào Hive box.\n'
          '• Bước 3: UI sẽ lắng nghe thay đổi của Hive box để cập nhật giao diện lập tức (ngay cả khi mất kết nối mạng, dữ liệu cũ vẫn hiển thị bình thường).',
    },
    {
      'title': 'Bảo mật hệ điều hành Ubuntu Server cho doanh nghiệp',
      'category': 'Networking',
      'author': 'Alex Pham',
      'readTime': '9 min',
      'isTrending': false,
      'content': 'Hệ điều hành Ubuntu Server là lựa chọn hàng đầu của doanh nghiệp, tuy nhiên cấu hình mặc định chưa đủ an toàn để chống lại các cuộc tấn công mạng.\n\n'
          'Các bước tăng cường bảo mật (Hardening):\n'
          '1. Cập nhật hệ thống: Chạy lệnh `sudo apt update && sudo apt upgrade` thường xuyên.\n'
          '2. Bảo mật SSH: Thay đổi cổng SSH mặc định 22 sang một cổng khác. Vô hiệu hóa đăng nhập bằng tài khoản root trực tiếp (`PermitRootLogin no`) và chuyển sang xác thực bằng SSH Key thay cho mật khẩu.\n'
          '3. Kích hoạt Firewall: Sử dụng UFW (Uncomplicated Firewall) để chỉ cho phép các cổng dịch vụ cần thiết (như 80, 443, cổng SSH mới) đi qua.',
    },
  ];

  // Hàm loại bỏ dấu tiếng Việt để tìm kiếm chính xác hơn
  String _removeDiacritics(String str) {
    const withDia = 'àáạảãâầấậẩẫăằắặẳẵèéẹẻẽêềếệểễìíịỉĩòóọỏõôồốộổỗơờớợởỡùúụủũưừứựửữỳýỵỷỹđ';
    const withoutDia = 'aaaaaaaaaaaaaaaaaeeeeeeeeeeeiiiiiooooooooooooooooouuuuuuuuuuuyyyyyd';
    String result = str.toLowerCase();
    for (int i = 0; i < withDia.length; i++) {
      result = result.replaceAll(withDia[i], withoutDia[i]);
    }
    return result;
  }

  List<Map<String, dynamic>> get _filteredArticles {
    final query = _removeDiacritics(_searchQuery).trim();
    
    return _articles.where((article) {
      final title = _removeDiacritics(article['title']);
      final category = _removeDiacritics(article['category']);
      
      // Kiểm tra khớp từ khóa (trong cả tiêu đề và danh mục)
      final matchesSearch = query.isEmpty || title.contains(query) || category.contains(query);
      
      // Kiểm tra khớp danh mục đang chọn trên thanh filter
      final matchesCategory = _selectedCategory == 'All' || article['category'] == _selectedCategory;
      
      return matchesSearch && matchesCategory;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);

    final List<Map<String, dynamic>> categories = [
      {'key': 'All', 'name': AppStrings.of(context, 'all'), 'icon': Icons.grid_view_rounded, 'color': Colors.white},
      {'key': 'Programming', 'name': AppStrings.of(context, 'catProgramming'), 'icon': Icons.code_rounded, 'color': const Color(0xFF7000FF)},
      {'key': 'Mobile', 'name': AppStrings.of(context, 'catMobile'), 'icon': Icons.phone_android_rounded, 'color': const Color(0xFFFF00D2)},
      {'key': 'Networking', 'name': AppStrings.of(context, 'catNetworking'), 'icon': Icons.hub_rounded, 'color': const Color(0xFF00D2FF)},
      {'key': 'Database', 'name': AppStrings.of(context, 'catDatabase'), 'icon': Icons.storage_rounded, 'color': const Color(0xFF00FF94)},
    ];

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      behavior: HitTestBehavior.opaque,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Thanh tìm kiếm
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 110, 20, 20),
          child: TextField(
            controller: _searchController,
            style: TextStyle(color: theme.colorScheme.onSurface),
            decoration: InputDecoration(
              hintText: AppStrings.of(context, 'searchHint'),
              hintStyle: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.4)),
              prefixIcon: Icon(Icons.search, color: theme.colorScheme.primary),
              suffixIcon: _searchQuery.isNotEmpty 
                ? IconButton(
                    icon: Icon(Icons.clear, color: theme.colorScheme.onSurface.withValues(alpha: 0.3), size: 20),
                    onPressed: () => _searchController.clear(),
                  )
                : null,
              filled: true,
              fillColor: isDark ? AppDesignTokens.msgBotBgDark : Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(22),
                borderSide: BorderSide(color: isDark ? Colors.white12 : Colors.black.withValues(alpha: 0.05)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(22),
                borderSide: BorderSide(color: isDark ? Colors.white12 : Colors.black.withValues(alpha: 0.05)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(22),
                borderSide: BorderSide(color: theme.colorScheme.primary, width: 1.5),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 18),
            ),
          ),
        ),

        // Danh mục (Categories)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            AppStrings.of(context, 'categoriesTitle'),
            style: TextStyle(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
              fontSize: 12,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 45,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 15),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              final isSelected = _selectedCategory == category['key'];
              final categoryColor = category['color'] as Color;
              
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: ChoiceChip(
                  label: Text(category['name']),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() => _selectedCategory = category['key']);
                  },
                  backgroundColor: isDark ? AppDesignTokens.msgBotBgDark : Colors.white,
                  selectedColor: isSelected 
                      ? (isDark ? categoryColor.withValues(alpha: 0.2) : theme.colorScheme.primary.withValues(alpha: 0.1))
                      : null,
                  labelStyle: TextStyle(
                    color: isSelected 
                        ? (isDark ? (categoryColor == Colors.white ? AppDesignTokens.colorPrimary : categoryColor) : theme.colorScheme.primary) 
                        : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 13,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: isSelected 
                          ? (isDark ? categoryColor.withValues(alpha: 0.5) : theme.colorScheme.primary.withValues(alpha: 0.3)) 
                          : (isDark ? Colors.white12 : Colors.black.withValues(alpha: 0.05)),
                    ),
                  ),
                  showCheckmark: false,
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 25),

        // Tiêu đề phần danh sách
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _searchQuery.isNotEmpty 
                  ? AppStrings.of(context, 'searchResults') 
                  : (_selectedCategory == 'All' 
                      ? AppStrings.of(context, 'recommendedForYou') 
                      : '${AppStrings.of(context, 'topicTitle')}: ${categories.firstWhere((c) => c['key'] == _selectedCategory)['name']}'),
                style: TextStyle(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  fontSize: 12,
                ),
              ),
              if (_filteredArticles.isNotEmpty)
                Text(
                  '${_filteredArticles.length} ${AppStrings.of(context, 'articlesCount')}',
                  style: TextStyle(color: theme.colorScheme.primary, fontSize: 11),
                ),
            ],
          ),
        ),

        Expanded(
          child: _filteredArticles.isEmpty
              ? _buildEmptyState(theme)
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 130),
                  itemCount: _filteredArticles.length,
                  itemBuilder: (context, index) => _buildArticleCard(context, _filteredArticles[index], isDark, theme),
                ),
        ),
      ],
    ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 60, color: theme.colorScheme.onSurface.withValues(alpha: 0.1)),
          const SizedBox(height: 16),
          Text(
            AppStrings.of(context, 'noArticlesFound'),
            style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.4)),
          ),
          if (_searchQuery.isNotEmpty)
            TextButton(
              onPressed: () => _searchController.clear(),
              child: Text(AppStrings.of(context, 'clearSearch'), style: TextStyle(color: theme.colorScheme.primary)),
            )
        ],
      ),
    );
  }

  Widget _buildArticleCard(BuildContext context, Map<String, dynamic> article, bool isDark, ThemeData theme) {
    final Color accentColor = isDark ? AppDesignTokens.colorPrimary : theme.colorScheme.primary;

    // Translate category display
    String categoryDisplay = article['category'];
    if (article['category'] == 'Programming') categoryDisplay = AppStrings.of(context, 'catProgramming');
    if (article['category'] == 'Mobile') categoryDisplay = AppStrings.of(context, 'catMobile');
    if (article['category'] == 'Networking') categoryDisplay = AppStrings.of(context, 'catNetworking');
    if (article['category'] == 'Database') categoryDisplay = AppStrings.of(context, 'catDatabase');

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ArticleDetailScreen(article: {
              ...article,
              'category': categoryDisplay, // Pass translated category
            }),
          ),
        );
      },
      borderRadius: BorderRadius.circular(24),
      child: Container(
        margin: const EdgeInsets.only(bottom: 18),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? AppDesignTokens.msgBotBgDark : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.04),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    categoryDisplay,
                    style: TextStyle(color: accentColor, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
                const Spacer(),
                if (article['isTrending'] == true)
                  Row(
                    children: [
                      const Icon(Icons.bolt, color: Colors.amber, size: 14),
                      Text(AppStrings.of(context, 'trending'), style: const TextStyle(color: Colors.amber, fontSize: 10)),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              AppStrings.of(context, article['title']),
              style: TextStyle(
                color: theme.colorScheme.onSurface,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.person_outline, color: theme.colorScheme.onSurface.withValues(alpha: 0.4), size: 14),
                const SizedBox(width: 4),
                Text(
                  article['author'], 
                  style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.4), fontSize: 12)
                ),
                const SizedBox(width: 15),
                Icon(Icons.access_time, color: theme.colorScheme.onSurface.withValues(alpha: 0.4), size: 14),
                const SizedBox(width: 4),
                Text(
                  article['readTime'], 
                  style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.4), fontSize: 12)
                ),
                const Spacer(),
                Icon(Icons.arrow_forward_rounded, color: accentColor, size: 18),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
