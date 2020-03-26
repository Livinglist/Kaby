extension ListExtension<T> on List<T> {
  void addIfNotExist(T t) {
    if (this.contains(t) == false) this.add(t);
  }
}
