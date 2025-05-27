import 'package:flutter/material.dart';
import 'package:ecommerceapp/pages/home/models/Fruitsmodel.dart';
import 'package:ecommerceapp/pages/food/screens/detailspage.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SearchPage extends StatefulWidget {
  final List<Getdata> fruits;

  const SearchPage({super.key, required this.fruits});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  List<Getdata> filtered = [];
  final TextEditingController _searchController = TextEditingController();
  List<String> recentSearches = [];

  

  // Save and load recent searches using SharedPreferences
  @override
  void initState() {
    super.initState();
    filtered = [];
    _loadRecentSearches();
    _searchController.addListener(_onSearch);
  }

  void _onSearch() {
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      if (query.isEmpty) {
        filtered = [];
      } else {
        filtered = widget.fruits
            .where((fruit) => (fruit.name ?? '').toLowerCase().contains(query))
            .toList();
      }
    });
  }

  // Add this method to handle search submission and update recent searches
  void _onSearchSubmitted(String value) async {
    final query = value.trim();
    if (query.isNotEmpty && !recentSearches.contains(query)) {
      setState(() {
        recentSearches.insert(0, query);
        // Optional: Limit recent searches to last 10
        if (recentSearches.length > 10) {
          recentSearches = recentSearches.sublist(0, 10);
        }
      });
      await _saveRecentSearches();
    }
    _onSearch();
  }

  Future<void> _saveRecentSearches() async {
    // Use SharedPreferences to persist recent searches
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('recent_searches', recentSearches);
  }

  Future<void> _loadRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    final searches = prefs.getStringList('recent_searches') ?? [];
    setState(() {
      recentSearches = searches;
    });
  }

  void _removeRecentSearch(String search) async {
    setState(() {
      recentSearches.remove(search);
    });
    await _saveRecentSearches();
  }

    // Only add to recent searches when user submits (not on every character)
    // So, do NOT add here on every letter typed.
  


  void _useRecentSearch(String search) {
    _searchController.text = search;
    _searchController.selection = TextSelection.fromPosition(
      TextPosition(offset: search.length),
    );
    _onSearch();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search by fruit name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          if (recentSearches.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                height: 40,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: recentSearches.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final search = recentSearches[index];
                    return Chip(
                      label: GestureDetector(
                        onTap: () => _useRecentSearch(search),
                        child: Text(search),
                      ),
                      deleteIcon: const Icon(Icons.close),
                      onDeleted: () => _removeRecentSearch(search),
                    );
                  },
                ),
              ),
            ),
          if (_searchController.text.trim().isNotEmpty)
            Expanded(
              child: filtered.isEmpty
                  ? const Center(child: Text('No fruits found'))
                  : ListView.builder(
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final fruit = filtered[index];
                        return ListTile(
                          leading: fruit.imageUrl != null
                              ? CircleAvatar(
                                  backgroundImage: CachedNetworkImageProvider(fruit.imageUrl!),
                                )
                              : const CircleAvatar(child: Icon(Icons.image)),
                          title: Text(fruit.name ?? ''),
                          subtitle: Text('\$${fruit.price ?? ''}'),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DetailsPage(id: fruit.id),
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
        ],
      ),
    );
  }
}