import 'dart:collection';

/// Simple LRU cache with a maximum size.
/// When the cache exceeds [maxSize], the least recently used entries are evicted.
class LruCache<K, V> {
  final int maxSize;
  final LinkedHashMap<K, V> _map = LinkedHashMap<K, V>();

  LruCache(this.maxSize) : assert(maxSize > 0);

  V? operator [](K key) {
    final value = _map.remove(key);
    if (value != null) {
      _map[key] = value;
    }
    return value;
  }

  void operator []=(K key, V value) {
    _map.remove(key);
    _map[key] = value;
    while (_map.length > maxSize) {
      _map.remove(_map.keys.first);
    }
  }

  bool containsKey(K key) => _map.containsKey(key);

  void clear() => _map.clear();

  int get length => _map.length;
}
