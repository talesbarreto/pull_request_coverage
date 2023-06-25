class PrintEmoji {
  final bool _isEmojiAllowed;

  const PrintEmoji(this._isEmojiAllowed);

  String call(String emoji, String replacement) {
    return _isEmojiAllowed ? emoji : replacement;
  }
}
