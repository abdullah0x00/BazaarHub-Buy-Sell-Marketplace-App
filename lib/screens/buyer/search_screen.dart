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
  final String? initialQuery;
  final bool triggerCamera;
  const SearchScreen({super.key, this.initialQuery, this.triggerCamera = false});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _ctrl = TextEditingController();
  bool _showFilters = false;
  final String _sortBy = 'Popularity';

  final List<String> _recent = [
    'Smartphone',
    'Shoes',
    'Watch',
    'Laptop'
  ];
  final List<String> _trending = [
    'Wireless Buds',
    'Smart Watch',
    'Bluetooth Speaker',
    'Football',
    'Sneakers',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialQuery != null) {
      _ctrl.text = widget.initialQuery!;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().loadHomeData();
      if (widget.initialQuery != null) {
        _onSearch(widget.initialQuery!);
      }
      if (widget.triggerCamera) {
        Future.delayed(const Duration(milliseconds: 300), () => _openImageSearch());
      }
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onSearch(String query) {
    if (query.trim().isEmpty) return;
    context.read<ProductProvider>().search(query);
    setState(() {});
  }

  void _openScanner() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SearchScannerScreen()),
    );
    if (result != null && result is String) {
      _ctrl.text = result;
      _onSearch(result);
    }
  }

  void _openImageSearch() async {
    final messenger = ScaffoldMessenger.of(context);
    final picker = ImagePicker();
    
    try {
      final image = await picker.pickImage(source: ImageSource.camera);
      if (image != null) {
        messenger.showSnackBar(const SnackBar(content: Text('Analyzing image...')));
        // Simulate finding an object in image
        Future.delayed(const Duration(seconds: 1), () {
           _ctrl.text = "Watch";
           _onSearch("Watch");
        });
      }
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Camera error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final products = context.watch<ProductProvider>();
    final hasQuery = _ctrl.text.isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Container(
          height: 45,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: _ctrl,
            autofocus: !widget.triggerCamera,
            decoration: InputDecoration(
              hintText: 'Search products...',
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              prefixIcon: const Icon(Icons.search, color: Colors.grey, size: 20),
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                   if (_ctrl.text.isNotEmpty) 
                      IconButton(
                        icon: const Icon(Icons.close, size: 18), 
                        onPressed: () { _ctrl.clear(); setState(() {}); }
                      ),
                   IconButton(
                     icon: const Icon(Icons.camera_alt_outlined, color: Colors.grey, size: 20), 
                     onPressed: _openImageSearch
                   ),
                   const SizedBox(width: 4),
                ],
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
            ),
            onChanged: (v) => setState(() {}),
            onSubmitted: _onSearch,
          ),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.qr_code_scanner, color: AppColors.primary), onPressed: _openScanner),
          TextButton(
            onPressed: () => _onSearch(_ctrl.text),
            child: const Text('Search', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
          ),
        ],
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.sort, size: 18, color: Colors.grey),
              const SizedBox(width: 4),
              Text(_sortBy, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
            ],
          ),
          InkWell(
            onTap: () => setState(() => _showFilters = !_showFilters),
            child: Row(
              children: [
                const Text('Filter', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                const SizedBox(width: 4),
                Icon(Icons.filter_list, size: 18, color: _showFilters ? AppColors.primary : Colors.grey),
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
        subtitle: 'No matches found for "${_ctrl.text}".',
      );
    }
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: products.searchResults.length,
      itemBuilder: (ctx, i) => ProductCard(product: products.searchResults[i]),
    );
  }

  Widget _buildSuggestions() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Recent Searches', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _recent.map((q) => _buildSearchChip(q)).toList(),
          ),
          const SizedBox(height: 32),
          const Text('Trending Now', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ..._trending.asMap().entries.map((e) => _buildTrendingTile(e.key + 1, e.value)),
        ],
      ),
    );
  }

  Widget _buildSearchChip(String text) {
    return InkWell(
      onTap: () {
        _ctrl.text = text;
        _onSearch(text);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey[300]!)
        ),
        child: Text(text, style: const TextStyle(fontSize: 13, color: Colors.black87)),
      ),
    );
  }

  Widget _buildTrendingTile(int rank, String text) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Text('#$rank', style: TextStyle(color: rank <= 3 ? AppColors.primary : Colors.grey, fontWeight: FontWeight.bold)),
      title: Text(text, style: const TextStyle(fontSize: 14)),
      trailing: const Icon(Icons.north_east, size: 16, color: Colors.grey),
      onTap: () {
        _ctrl.text = text;
        _onSearch(text);
      },
    );
  }
}
