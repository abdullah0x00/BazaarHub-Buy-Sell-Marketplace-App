import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../config/theme.dart';
import '../../providers/product_provider.dart';
import '../../widgets/product_card.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/empty_state_widget.dart';
import 'search_scanner_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _ctrl = TextEditingController();
  final _debounce = ValueNotifier<String>('');
  bool _showFilters = false;
  String? _sortBy = 'Popularity';

  final List<String> _recent = [
    'iPhone 15',
    'Nike shoes',
    'Samsung TV',
    'Gaming Mouse'
  ];
  final List<String> _trending = [
    'Wireless Earbuds',
    'Smart Watch',
    'Bluetooth Speaker',
    'Mechanical Keyboard',
    'Gaming Chair',
  ];

  @override
  void initState() {
    super.initState();
    _ctrl.addListener(() {
      _debounce.value = _ctrl.text;
      if (_ctrl.text.isNotEmpty) {
        Future.delayed(const Duration(milliseconds: 400), () {
          if (_ctrl.text == _debounce.value && mounted) {
            context.read<ProductProvider>().search(_ctrl.text);
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _debounce.dispose();
    super.dispose();
  }

  void _openScanner() async {
    final provider = context.read<ProductProvider>();
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SearchScannerScreen()),
    );
    if (result != null && result is String) {
      _ctrl.text = result;
      // Trigger search
      if (mounted) provider.search(result);
      setState(() {});
    }
  }

  void _openImageSearch() async {
    final messenger = ScaffoldMessenger.of(context);
    final provider = context.read<ProductProvider>();

    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      // simulate search by image
      messenger.showSnackBar(
        const SnackBar(content: Text('Searching by image...')),
      );
      // for demo, search for "Gadget"
      _ctrl.text = "Gadget";
      if (mounted) provider.search("Gadget");
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final products = context.watch<ProductProvider>();
    final hasQuery = _ctrl.text.isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: SafeArea(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 2,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
                Expanded(
                  child: Container(
                    height: 45,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Row(
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(left: 12, right: 8),
                          child: Icon(Icons.search, color: Colors.grey),
                        ),
                        Expanded(
                          child: TextField(
                            controller: _ctrl,
                            autofocus: true,
                            decoration: const InputDecoration(
                              hintText: 'Search in Marketplace...',
                              border: InputBorder.none,
                              hintStyle:
                                  TextStyle(fontSize: 14, color: Colors.grey),
                            ),
                            onSubmitted: (q) =>
                                context.read<ProductProvider>().search(q),
                          ),
                        ),
                        if (hasQuery)
                          IconButton(
                            icon: const Icon(Icons.close, size: 18),
                            onPressed: () {
                              _ctrl.clear();
                              setState(() {});
                            },
                          )
                        else ...[
                          IconButton(
                            icon: const Icon(Icons.qr_code_scanner,
                                color: AppColors.primary, size: 20),
                            onPressed: _openScanner,
                            tooltip: 'Scan QR',
                          ),
                          IconButton(
                            icon: const Icon(Icons.camera_alt_outlined,
                                color: AppColors.primary, size: 20),
                            onPressed: _openImageSearch,
                            tooltip: 'Search by Image',
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () =>
                      context.read<ProductProvider>().search(_ctrl.text),
                  child: const Text('Search',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary)),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          if (hasQuery) _buildFiltersRow(),
          Expanded(
            child: hasQuery ? _buildResults(products) : _buildSuggestions(),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltersRow() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Sort Dropdown (Mock)
          Row(
            children: [
              const Icon(Icons.sort, size: 18, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              DropdownButton<String>(
                value: _sortBy,
                underline: const SizedBox(),
                items: [
                  'Popularity',
                  'Price: Low to High',
                  'Price: High to Low',
                  'Newest'
                ]
                    .map((s) => DropdownMenuItem(
                        value: s,
                        child: Text(s, style: const TextStyle(fontSize: 12))))
                    .toList(),
                onChanged: (v) => setState(() => _sortBy = v),
              ),
            ],
          ),
          // Filter Button (Mock)
          InkWell(
            onTap: () => setState(() => _showFilters = !_showFilters),
            child: Row(
              children: [
                const Text('Filter',
                    style:
                        TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                const SizedBox(width: 4),
                Icon(Icons.filter_list,
                    size: 18,
                    color: _showFilters
                        ? AppColors.primary
                        : AppColors.textSecondary),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResults(ProductProvider products) {
    if (products.isLoading) return const LoadingWidget();
    if (products.searchResults.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.search_off,
        title: 'No Results Found',
        subtitle: 'We couldn\'t find any matches for "${_ctrl.text}".',
      );
    }
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.65,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: products.searchResults.length,
      itemBuilder: (ctx, i) => ProductCard(product: products.searchResults[i]),
    );
  }

  Widget _buildSuggestions() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Searches',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary),
              ),
              IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.delete_outline,
                      size: 20, color: Colors.grey)),
            ],
          ),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _recent.map((q) => _buildSearchChip(q)).toList(),
          ),
          const SizedBox(height: 30),
          const Text(
            'Trending Searches',
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary),
          ),
          const SizedBox(height: 12),
          ..._trending
              .asMap()
              .entries
              .map((e) => _buildTrendingTile(e.key + 1, e.value)),
        ],
      ),
    );
  }

  Widget _buildSearchChip(String text) {
    return InkWell(
      onTap: () {
        _ctrl.text = text;
        context.read<ProductProvider>().search(text);
        setState(() {});
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(text,
            style:
                const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
      ),
    );
  }

  Widget _buildTrendingTile(int rank, String text) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 25,
        alignment: Alignment.center,
        child: Text('#$rank',
            style: TextStyle(
              color: rank <= 3 ? AppColors.primary : Colors.grey,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            )),
      ),
      title: Text(text, style: const TextStyle(fontSize: 14)),
      trailing: const Icon(Icons.trending_up, size: 18, color: Colors.grey),
      onTap: () {
        _ctrl.text = text;
        context.read<ProductProvider>().search(text);
        setState(() {});
      },
    );
  }
}
