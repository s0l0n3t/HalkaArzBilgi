import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:halkaarzbilgi/features/news/models/news_model.dart';
import 'package:halkaarzbilgi/features/news/news_detail_screen.dart';

void main() {
  testWidgets('NewsDetailScreen renders correctly with news details, AI comment, and Aa sheet',
      (WidgetTester tester) async {
    final news = NewsModel.mockNews.first;

    await tester.pumpWidget(
      MaterialApp(
        home: NewsDetailScreen(
          id: news.id,
          news: news,
        ),
      ),
    );

    // Verify app bar, headline, summary box
    expect(find.text('Haber Detayı'), findsOneWidget);
    expect(find.text(news.title), findsOneWidget);
    expect(find.text('Haber Özeti'), findsOneWidget);
    expect(find.text(news.summary), findsOneWidget);

    // Verify Yapay Zeka Yorumu card and disclaimer
    expect(find.text('Yapay Zeka Yorumu'), findsOneWidget);
    expect(find.text(news.aiComment), findsOneWidget);
    expect(
      find.text('Asla bir yatırım tavsiyesi değildir. Bilgi vermeyi amaçlamaktadır.'),
      findsOneWidget,
    );

    // Verify okuma süresi and SON DAKİKA are NOT present
    expect(find.textContaining('okuma süresi'), findsNothing);
    expect(find.text('SON DAKİKA'), findsNothing);

    // Verify Share and font size (Aa) buttons
    expect(find.byTooltip('Haberi Paylaş'), findsOneWidget);
    final fontButton = find.byTooltip('Yazı Boyutu');
    expect(fontButton, findsOneWidget);

    // Open Aa bottom sheet
    await tester.tap(fontButton);
    await tester.pumpAndSettle();

    expect(find.text('Yazı Boyutu'), findsWidgets);
    expect(find.text('Küçük'), findsOneWidget);
    expect(find.text('Standart'), findsWidgets);
    expect(find.text('Büyük'), findsOneWidget);

    // Tap 'Büyük'
    await tester.tap(find.text('Büyük'));
    await tester.pumpAndSettle();
  });
}
