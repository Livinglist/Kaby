extension ListExtension<T> on List<T> {
  void addIfNotExist(T t) {
    if (this.contains(t) == false) this.add(t);
  }

  List<T> whereNotType<E extends T>() {
    List<T> a = [];
    for (var i in this) {
      if ((i is E) == false) {
        a.add(i);
      }
    }
    return a;
  }
}
