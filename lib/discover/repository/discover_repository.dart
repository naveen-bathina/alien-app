class DiscoverRepository {
  Future<List<String>> fetchDiscoverItems() async {
    // Simulate a network call
    await Future<void>.delayed(const Duration(seconds: 2));
    return List.generate(10, (index) => 'Item $index');
  }
}
