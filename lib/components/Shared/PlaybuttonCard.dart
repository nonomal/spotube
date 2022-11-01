import 'package:fluent_ui/fluent_ui.dart' as FluentUI;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:platform_ui/platform_ui.dart';
import 'package:spotube/components/Shared/HoverBuilder.dart';
import 'package:spotube/components/Shared/SpotubeMarqueeText.dart';
import 'package:spotube/components/Shared/UniversalImage.dart';
import 'package:spotube/hooks/usePlatformProperty.dart';

class PlaybuttonCard extends HookWidget {
  final void Function()? onTap;
  final void Function()? onPlaybuttonPressed;
  final String? description;
  final EdgeInsetsGeometry? margin;
  final String imageUrl;
  final bool isPlaying;
  final bool isLoading;
  final String title;
  const PlaybuttonCard({
    required this.imageUrl,
    required this.isPlaying,
    required this.isLoading,
    required this.title,
    this.margin,
    this.description,
    this.onPlaybuttonPressed,
    this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final backgroundColor = PlatformTheme.of(context).secondaryBackgroundColor;

    final boxShadow = usePlatformProperty<BoxShadow?>(
      (context) => PlatformProperty(
        android: BoxShadow(
          blurRadius: 10,
          offset: const Offset(0, 3),
          spreadRadius: 5,
          color: Theme.of(context).shadowColor,
        ),
        ios: null,
        macos: null,
        linux: BoxShadow(
          blurRadius: 10,
          offset: const Offset(0, 3),
          spreadRadius: 5,
          color: Theme.of(context).shadowColor,
        ),
        windows: null,
      ),
    );

    final titleStyle = PlatformTextTheme.of(context).body;

    final descriptionStyle = PlatformTextTheme.of(context).caption;

    final splash = usePlatformProperty<InteractiveInkFeatureFactory?>(
      (context) => PlatformProperty.multiPlatformGroup({
        InkRipple.splashFactory: {TargetPlatform.android, TargetPlatform.linux},
        NoSplash.splashFactory: {
          TargetPlatform.windows,
          TargetPlatform.macOS,
          TargetPlatform.iOS,
        }
      }),
    );

    final iconBgColor = PlatformTheme.of(context).primaryColor;

    return Container(
      margin: margin,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        splashFactory: splash,
        highlightColor: Colors.black12,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 200),
          child: HoverBuilder(builder: (context, isHovering) {
            return Ink(
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(
                  platform == TargetPlatform.windows ? 5 : 8,
                ),
                boxShadow: [
                  if (boxShadow != null) boxShadow,
                ],
                border: [TargetPlatform.windows, TargetPlatform.macOS]
                        .contains(platform)
                    ? Border.all(
                        color: PlatformTheme.of(context).borderColor ??
                            Colors.transparent,
                        width: 1,
                      )
                    : null,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // thumbnail of the playlist
                  Stack(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(
                          platform == TargetPlatform.windows ? 5 : 0,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(
                            platform == TargetPlatform.windows ? 5 : 8,
                          ),
                          child: UniversalImage(
                            path: imageUrl,
                            width: 200,
                            placeholder: (context, url) =>
                                Image.asset("assets/placeholder.png"),
                          ),
                        ),
                      ),
                      Positioned.directional(
                        textDirection: TextDirection.ltr,
                        bottom: 10,
                        end: 5,
                        child: Builder(builder: (context) {
                          return Container(
                            decoration: BoxDecoration(
                              color: iconBgColor,
                              shape: BoxShape.circle,
                            ),
                            child: PlatformIconButton(
                              onPressed: onPlaybuttonPressed,
                              icon: isLoading
                                  ? const SizedBox(
                                      height: 23,
                                      width: 23,
                                      child:
                                          PlatformCircularProgressIndicator(),
                                    )
                                  : Icon(
                                      isPlaying
                                          ? Icons.pause_rounded
                                          : Icons.play_arrow_rounded,
                                      color: backgroundColor,
                                    ),
                            ),
                          );
                        }),
                      )
                    ],
                  ),
                  const SizedBox(height: 5),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    child: Column(
                      children: [
                        Tooltip(
                          message: title,
                          child: SizedBox(
                            height: 20,
                            child: SpotubeMarqueeText(
                              text: title,
                              style: titleStyle?.copyWith(
                                  fontWeight: FontWeight.bold),
                              isHovering: isHovering,
                            ),
                          ),
                        ),
                        if (description != null) ...[
                          const SizedBox(height: 10),
                          SizedBox(
                            height: 30,
                            child: SpotubeMarqueeText(
                              text: description!,
                              style: descriptionStyle,
                              isHovering: isHovering,
                            ),
                          ),
                        ]
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}
