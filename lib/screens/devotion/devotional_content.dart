// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:youth_guide/screens/devotion/devotional_section.dart';
import 'package:youth_guide/screens/journal/journal_screen.dart';
import 'package:youth_guide/service/api_service.dart';
import 'package:youth_guide/service/providers/font_provider.dart';
import 'package:youth_guide/service/providers/theme_provider.dart';
import 'package:youth_guide/service/providers/tts_provider.dart';
import 'package:youth_guide/utils.dart';
import 'package:youth_guide/utils/app_colors.dart';
import 'package:youth_guide/utils/functions.dart';

class DevotionalContent extends StatelessWidget {
  const DevotionalContent({
    super.key,
    required ScrollController scrollController,
    required this.dailyDevotional,
    required this.themeProvider,
    required bool isCollapsed,
    required this.formattedDate,
    required this.ttsProvider,
    required this.devotionText,
    required this.fontSize,
    required this.fontSizeProvider,
    required this.content,
    required this.reference,
  }) : _scrollController = scrollController,
       _isCollapsed = isCollapsed;

  final ScrollController _scrollController;
  final Map<String, dynamic> dailyDevotional;
  final ThemeProvider themeProvider;
  final bool _isCollapsed;
  final String? formattedDate;
  final TtsProvider ttsProvider;
  final List<String> devotionText;
  final double fontSize;
  final FontSizeProvider fontSizeProvider;
  final String? content;
  final String? reference;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        SliverAppBar(
          expandedHeight: 200.0,
          floating: false,
          pinned: true,
          backgroundColor:
              themeProvider.isDarkMode
                  ? AppColors.appBlackColor
                  : AppColors.appWhiteColor,

          flexibleSpace: FlexibleSpaceBar(
            titlePadding: EdgeInsets.only(
              left: _isCollapsed ? 50 : 72,
              bottom: 16,
            ),
            title: Text(
              'Daily Devotional',
              style: GoogleFonts.lora(
                textStyle: TextStyle(
                  color:
                      !themeProvider.isDarkMode && _isCollapsed
                          ? AppColors.appBlackColor
                          : !themeProvider.isDarkMode && !_isCollapsed
                          ? AppColors.appWhiteColor
                          : themeProvider.isDarkMode && !_isCollapsed
                          ? AppColors.appBlackColor
                          : AppColors.appWhiteColor,
                ),
              ),
            ),

            background: Container(
              decoration: BoxDecoration(
                color:
                    themeProvider.isDarkMode
                        ? AppColors.appGoldColor
                        : AppColors.appGreyColor,
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      formattedDate!
                          .split(' ')
                          .sublist(0, formattedDate!.split(' ').length - 1)
                          .join(' '),
                      style: TextStyle(
                        color:
                            themeProvider.isDarkMode
                                ? AppColors.appBlackColor.withAlpha(150)
                                : AppColors.appLighterGreyColor,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      formattedDate!.split(' ').last,
                      style: TextStyle(
                        color:
                            themeProvider.isDarkMode
                                ? AppColors.appBlackColor
                                : AppColors.appWhiteColor,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          leading: IconButton(
            icon:
                !themeProvider.isDarkMode
                    ? Icon(
                      Icons.arrow_back,
                      color:
                          _isCollapsed
                              ? AppColors.appBlackColor
                              : AppColors.appWhiteColor,
                    )
                    : Icon(
                      Icons.arrow_back,
                      color:
                          _isCollapsed
                              ? AppColors.appWhiteColor
                              : AppColors.appBlackColor,
                    ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          actions: [
            IconButton(
              visualDensity: VisualDensity.compact,
              icon:
                  !themeProvider.isDarkMode
                      ? Icon(
                        Icons.share,
                        color:
                            _isCollapsed
                                ? AppColors.appBlackColor
                                : AppColors.appWhiteColor,
                      )
                      : Icon(
                        Icons.share,
                        color:
                            _isCollapsed
                                ? AppColors.appWhiteColor
                                : AppColors.appBlackColor,
                      ),
              onPressed: () {
                Share.share(
                  shareDevotion(
                    date: formattedDate ?? "",
                    topic: dailyDevotional['topic'],
                    text: dailyDevotional['text'],
                    memoryVerse: dailyDevotional['memory verse'],
                    message: dailyDevotional['message'],
                    wisdomShot: dailyDevotional['wisdom shot'],
                    prayer: dailyDevotional['prayer'],
                  ),
                );
              },
            ),
            IconButton(
              visualDensity: VisualDensity.compact,
              icon:
                  !themeProvider.isDarkMode
                      ? Icon(
                        Icons.book,
                        color:
                            _isCollapsed
                                ? AppColors.appBlackColor
                                : AppColors.appWhiteColor,
                      )
                      : Icon(
                        Icons.book,
                        color:
                            _isCollapsed
                                ? AppColors.appWhiteColor
                                : AppColors.appBlackColor,
                      ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => JournalListScreen()),
                );
              },
            ),
            IconButton(
              visualDensity: VisualDensity.compact,
              icon:
                  !themeProvider.isDarkMode
                      ? Icon(
                        ttsProvider.state == TtsState.playing
                            ? Icons.pause_circle_filled
                            : Icons.play_circle_filled,
                        color:
                            _isCollapsed
                                ? AppColors.appBlackColor
                                : AppColors.appWhiteColor,
                      )
                      : Icon(
                        ttsProvider.state == TtsState.playing
                            ? Icons.pause_circle_filled
                            : Icons.play_circle_filled,
                        color:
                            _isCollapsed
                                ? AppColors.appWhiteColor
                                : AppColors.appBlackColor,
                      ),
              onPressed: () {
                ttsProvider.setTexts(devotionText);
                togglePlayPause(ttsProvider);
              },
            ),
            PopupMenuButton(
              icon: Icon(
                Icons.more_vert,
                color:
                    !themeProvider.isDarkMode
                        ? _isCollapsed
                            ? AppColors.appBlackColor
                            : AppColors.appWhiteColor
                        : _isCollapsed
                        ? AppColors.appWhiteColor
                        : AppColors.appBlackColor,
              ),

              itemBuilder:
                  (context) => [
                    PopupMenuItem(
                      child: Text('Decrease font'),
                      onTap: () {
                        if (fontSize <= 12) return;
                        fontSizeProvider.setFontSize(fontSize - 2);
                      },
                    ),
                    PopupMenuItem(
                      child: Text('Increase font'),
                      onTap: () {
                        if (fontSize >= 20) return;
                        fontSizeProvider.setFontSize(fontSize + 2);
                      },
                    ),
                  ],
            ),
          ],
        ),
        SliverToBoxAdapter(
          child: Container(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DevotionalSection(
                  title: 'TOPIC',
                  content: dailyDevotional['topic'],
                  fontSize: fontSize,
                  isDarkMode: themeProvider.isDarkMode,
                ),
                DevotionalSection(
                  title: 'TEXT',
                  content: dailyDevotional['text'],
                  fontSize: fontSize,
                  onTap: () {
                    // Open Bible reader with this reference
                  },
                  isDarkMode: themeProvider.isDarkMode,
                ),
                DevotionalSection(
                  title: 'MEMORY VERSE',
                  content: content ?? '',
                  reference: reference ?? '',
                  fontSize: fontSize,
                  isDarkMode: themeProvider.isDarkMode,
                  onTap: () async {
                    if (reference != null && reference!.isNotEmpty) {
                      final verseData = await BibleService()
                          .getVerseFromReference(reference!);

                      if (verseData.isNotEmpty) {
                        final verse = verseData.first;
                        showModalBottomSheet(
                          context: context,
                          backgroundColor:
                              themeProvider.isDarkMode
                                  ? AppColors.appGoldColor
                                  : AppColors.appGreyColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(16),
                            ),
                          ),
                          builder:
                              (_) => Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Text(
                                  '${verse['book']} ${verse['chapter']}:${verse['verse']} - ${verse['text']}',
                                  style: GoogleFonts.merriweatherSans(
                                    fontSize: fontSize,
                                    color:
                                        themeProvider.isDarkMode
                                            ? AppColors.appBlackColor.withAlpha(
                                              200,
                                            )
                                            : AppColors.appBlackColor.withAlpha(
                                              200,
                                            ),
                                  ),
                                ),
                              ),
                        );
                      }
                    }
                  },
                ),
                DevotionalSection(
                  title: 'MESSAGE',
                  content: dailyDevotional['message'] ?? '',
                  fontSize: fontSize,
                  isDarkMode: themeProvider.isDarkMode,
                ),
                DevotionalSection(
                  title: 'WISDOM SHOT',
                  content: dailyDevotional['wisdom shot'] ?? '',
                  fontSize: fontSize,
                  isQuote: true,
                  isDarkMode: themeProvider.isDarkMode,
                ),
                DevotionalSection(
                  title: 'PRAYER',
                  content: dailyDevotional['prayer'] ?? '',
                  fontSize: fontSize,
                  isPrayer: true,
                  isDarkMode: themeProvider.isDarkMode,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
