import 'package:flutter/material.dart';
import '../../services/store_service.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final _svc = StoreService();
  final _scroll = ScrollController();
  final _searchCtrl = TextEditingController();

  bool loading = true;
  bool loadingMore = false;
  bool reachedEnd = false;
  String? error;
  String? categoryId;
  String query = '';
  int page = 1;
  final List<Map<String, dynamic>> items = [];

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    categoryId = args?['id']?.toString();
    _refresh();
  }

  void _onScroll() {
    if (loadingMore || loading || reachedEnd) return;
    if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  Future<void> _refresh() async {
    setState(() {
      loading = true;
      error = null;
      page = 1;
      reachedEnd = false;
      items.clear();
    });
    try {
      final data = await _svc.products(categoryId: categoryId, query: query, page: page);
      items.addAll(data);
      if (data.length < 20) reachedEnd = true;
    } catch (_) {
      error = 'Failed to load products';
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> _loadMore() async {
    if (reachedEnd) return;
    setState(() => loadingMore = true);
    try {
      final data = await _svc.products(categoryId: categoryId, query: query, page: page + 1);
      if (data.isEmpty) {
        reachedEnd = true;
      } else {
        page += 1;
        items.addAll(data);
      }
    } catch (_) {
      // ignore load more errors
    } finally {
      if (mounted) setState(() => loadingMore = false);
    }
  }

  @override
  void dispose() {
    _scroll.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final green = Theme.of(context).colorScheme.primary;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: TextField(
          controller: _searchCtrl,
          decoration: const InputDecoration(
            hintText: 'Search products',
            border: InputBorder.none,
          ),
          style: const TextStyle(color: Colors.white),
          textInputAction: TextInputAction.search,
          onSubmitted: (v) {
            query = v.trim();
            _refresh();
          },
        ),
        backgroundColor: Colors.black,
        foregroundColor: green,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(error!, style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 12),
                      ElevatedButton(onPressed: _refresh, child: const Text('Retry')),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _refresh,
                  child: ListView.builder(
                    controller: _scroll,
                    padding: const EdgeInsets.all(16),
                    itemCount: items.length + (loadingMore ? 1 : 0),
                    itemBuilder: (_, i) {
                      if (i >= items.length) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                        );
                      }
                      final p = items[i];
                      return Card(
                        color: Colors.black,
                        child: ListTile(
                          title: Text((p['name'] ?? '').toString(), style: TextStyle(color: green)),
                          subtitle: Text('\$${(p['price'] as num?)?.toStringAsFixed(2) ?? '0.00'}',
                              style: const TextStyle(color: Colors.white70)),
                          trailing: const Icon(Icons.chevron_right, color: Colors.white70),
                          onTap: () => Navigator.pushNamed(context, '/product_details', arguments: p),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
