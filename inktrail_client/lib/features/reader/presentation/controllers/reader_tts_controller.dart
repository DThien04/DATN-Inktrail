import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

class ReaderTtsController {
  static const int _maxChunkChars = 2600;

  ReaderTtsController({
    this.onStateChanged,
    this.onProgress,
    this.onError,
  });

  final VoidCallback? onStateChanged;
  final void Function(
    int currentChunk,
    int totalChunks,
    int? activeParagraph,
    int? activeSentence,
  )? onProgress;
  final void Function(String error)? onError;

  final FlutterTts _tts = FlutterTts();
  bool _initialized = false;
  bool _isPlaying = false;
  bool _isPaused = false;
  double _speechRate = 0.5;
  double _pitch = 1.0;
  List<String> _chunks = const <String>[];
  List<int?> _chunkParagraphIndexes = const <int?>[];
  List<int?> _chunkSentenceIndexes = const <int?>[];
  int _chunkIndex = 0;

  bool get isPlaying => _isPlaying;
  bool get isPaused => _isPaused;
  double get speechRate => _speechRate;
  int get currentChunkIndex => _chunkIndex;
  int get totalChunks => _chunks.length;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    _tts.setCompletionHandler(() {
      if (!_isPlaying) return;
      _chunkIndex += 1;
      final activeParagraph = _chunkIndex < _chunkParagraphIndexes.length
          ? _chunkParagraphIndexes[_chunkIndex]
          : null;
      final activeSentence = _chunkIndex < _chunkSentenceIndexes.length
          ? _chunkSentenceIndexes[_chunkIndex]
          : null;
      onProgress?.call(
        _chunkIndex,
        _chunks.length,
        activeParagraph,
        activeSentence,
      );
      if (_chunkIndex >= _chunks.length) {
        _isPlaying = false;
        _isPaused = false;
        onProgress?.call(_chunkIndex, _chunks.length, null, null);
        onStateChanged?.call();
        return;
      }
      unawaited(_speakCurrentChunk());
    });

    _tts.setErrorHandler((message) {
      _isPlaying = false;
      _isPaused = false;
      onStateChanged?.call();
      onError?.call(message);
    });

    await _tts.awaitSpeakCompletion(true);
    await _tts.setLanguage('vi-VN');
    await _tts.setSpeechRate(_speechRate);
    await _tts.setPitch(_pitch);
  }

  Future<void> speakChapter({
    required String chapterTitle,
    required List<String> paragraphs,
  }) async {
    await init();
    await stop();

    _chunks = <String>[];
    _chunkParagraphIndexes = <int?>[];
    _chunkSentenceIndexes = <int?>[];
    final normalizedTitle = chapterTitle.trim();
    if (normalizedTitle.isNotEmpty) {
      _appendChunksFromText(
        normalizedTitle,
        paragraphIndex: null,
        sentenceIndex: null,
      );
    }
    for (var i = 0; i < paragraphs.length; i++) {
      final paragraph = paragraphs[i].trim();
      if (paragraph.isEmpty) continue;
      final sentences = _splitIntoSentences(paragraph);
      if (sentences.isEmpty) {
        _appendChunksFromText(
          paragraph,
          paragraphIndex: i,
          sentenceIndex: 0,
        );
        continue;
      }
      for (var sentenceIndex = 0; sentenceIndex < sentences.length; sentenceIndex++) {
        _appendChunksFromText(
          sentences[sentenceIndex],
          paragraphIndex: i,
          sentenceIndex: sentenceIndex,
        );
      }
    }

    if (_chunks.isEmpty) {
      onError?.call('Chương này chưa có nội dung để đọc.');
      return;
    }

    _chunkIndex = 0;
    _isPlaying = true;
    _isPaused = false;
    onStateChanged?.call();
    final activeParagraph = _chunkParagraphIndexes.isNotEmpty
        ? _chunkParagraphIndexes.first
        : null;
    final activeSentence = _chunkSentenceIndexes.isNotEmpty
        ? _chunkSentenceIndexes.first
        : null;
    onProgress?.call(
      _chunkIndex,
      _chunks.length,
      activeParagraph,
      activeSentence,
    );
    unawaited(_speakCurrentChunk());
  }

  Future<void> pause() async {
    if (!_isPlaying) return;
    await _tts.pause();
    _isPlaying = false;
    _isPaused = true;
    onStateChanged?.call();
  }

  Future<void> resume() async {
    if (!_isPaused || _chunks.isEmpty) return;
    _isPaused = false;
    _isPlaying = true;
    onStateChanged?.call();
    unawaited(_speakCurrentChunk());
  }

  Future<void> stop() async {
    await _tts.stop();
    _isPlaying = false;
    _isPaused = false;
    _chunkIndex = 0;
    _chunks = const <String>[];
    _chunkParagraphIndexes = const <int?>[];
    _chunkSentenceIndexes = const <int?>[];
    onStateChanged?.call();
    onProgress?.call(0, 0, null, null);
  }

  Future<void> setSpeechRate(double value) async {
    _speechRate = value.clamp(0.2, 0.8);
    await _tts.setSpeechRate(_speechRate);
    onStateChanged?.call();
  }

  Future<void> setPitch(double value) async {
    _pitch = value.clamp(0.7, 1.3);
    await _tts.setPitch(_pitch);
    onStateChanged?.call();
  }

  Future<void> dispose() async {
    await _tts.stop();
  }

  Future<void> _speakCurrentChunk() async {
    if (!_isPlaying || _chunkIndex < 0 || _chunkIndex >= _chunks.length) return;
    await _tts.speak(_chunks[_chunkIndex]);
  }

  void _appendChunksFromText(
    String text, {
    required int? paragraphIndex,
    required int? sentenceIndex,
  }) {
    final chunks = _splitIntoChunks(text);
    if (chunks.isEmpty) return;
    _chunks = List<String>.from(_chunks)..addAll(chunks);
    _chunkParagraphIndexes = List<int?>.from(_chunkParagraphIndexes)
      ..addAll(List<int?>.filled(chunks.length, paragraphIndex));
    _chunkSentenceIndexes = List<int?>.from(_chunkSentenceIndexes)
      ..addAll(List<int?>.filled(chunks.length, sentenceIndex));
  }

  List<String> _splitIntoSentences(String text) {
    return text
        .trim()
        .split(RegExp(r'(?<=[\.\!\?…])\s+'))
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();
  }

  List<String> _splitIntoChunks(String text) {
    final normalized = text.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (normalized.isEmpty) return const <String>[];

    final sentences = normalized
        .split(RegExp(r'(?<=[\.\!\?…])\s+'))
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();
    if (sentences.isEmpty) return <String>[normalized];

    final chunks = <String>[];
    final buffer = StringBuffer();

    void flushBuffer() {
      final value = buffer.toString().trim();
      if (value.isNotEmpty) chunks.add(value);
      buffer.clear();
    }

    for (final sentence in sentences) {
      if (sentence.length > _maxChunkChars) {
        if (buffer.isNotEmpty) flushBuffer();
        final words = sentence.split(' ');
        final longBuffer = StringBuffer();
        for (final word in words) {
          final next = longBuffer.isEmpty ? word : '${longBuffer.toString()} $word';
          if (next.length > _maxChunkChars) {
            final value = longBuffer.toString().trim();
            if (value.isNotEmpty) chunks.add(value);
            longBuffer
              ..clear()
              ..write(word);
          } else {
            if (longBuffer.isNotEmpty) longBuffer.write(' ');
            longBuffer.write(word);
          }
        }
        final remain = longBuffer.toString().trim();
        if (remain.isNotEmpty) chunks.add(remain);
        continue;
      }

      final nextText = buffer.isEmpty
          ? sentence
          : '${buffer.toString().trim()} $sentence';
      if (nextText.length > _maxChunkChars) {
        flushBuffer();
        buffer.write(sentence);
      } else {
        if (buffer.isNotEmpty) buffer.write(' ');
        buffer.write(sentence);
      }
    }

    if (buffer.isNotEmpty) flushBuffer();
    return chunks;
  }
}
