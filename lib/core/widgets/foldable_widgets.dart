import 'package:flutter/material.dart';

class Responsive {
  static const double mobileBreakpoint = 480;
  static const double tabletBreakpoint = 768;
  static const double desktopBreakpoint = 1024;
  static const double largeDesktopBreakpoint = 1440;

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < mobileBreakpoint;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= mobileBreakpoint &&
      MediaQuery.of(context).size.width < tabletBreakpoint;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= tabletBreakpoint &&
      MediaQuery.of(context).size.width < desktopBreakpoint;

  static bool isLargeDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= largeDesktopBreakpoint;

  static double widthPercent(BuildContext context, double percent) =>
      MediaQuery.of(context).size.width * (percent / 100);

  static double heightPercent(BuildContext context, double percent) =>
      MediaQuery.of(context).size.height * (percent / 100);
}

class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;
  final Widget? largeDesktop;

  const ResponsiveLayout({
    Key? key,
    required this.mobile,
    this.tablet,
    this.desktop,
    this.largeDesktop,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= Responsive.largeDesktopBreakpoint) {
          return largeDesktop ?? desktop ?? tablet ?? mobile;
        }
        if (constraints.maxWidth >= Responsive.desktopBreakpoint) {
          return desktop ?? tablet ?? mobile;
        }
        if (constraints.maxWidth >= Responsive.tabletBreakpoint) {
          return tablet ?? mobile;
        }
        return mobile;
      },
    );
  }
}

class ResponsiveValue<T> {
  final T mobile;
  final T? tablet;
  final T? desktop;
  final T? largeDesktop;

  const ResponsiveValue({
    required this.mobile,
    this.tablet,
    this.desktop,
    this.largeDesktop,
  });

  T get(BuildContext context) {
    if (Responsive.isLargeDesktop(context)) {
      return largeDesktop ?? desktop ?? tablet ?? mobile;
    }
    if (Responsive.isDesktop(context)) {
      return desktop ?? tablet ?? mobile;
    }
    if (Responsive.isTablet(context)) {
      return tablet ?? mobile;
    }
    return mobile;
  }
}

class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final double? maxWidth;
  final double? maxHeight;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Alignment alignment;
  final BoxConstraints? constraints;

  const ResponsiveContainer({
    Key? key,
    required this.child,
    this.maxWidth,
    this.maxHeight,
    this.padding,
    this.margin,
    this.alignment = Alignment.center,
    this.constraints,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? _getDefaultPadding(context),
      margin: margin,
      alignment: alignment,
      constraints: (constraints ?? BoxConstraints()).copyWith(
        maxWidth: maxWidth ?? _getMaxWidth(context),
        maxHeight: maxHeight,
      ),
      child: child,
    );
  }

  EdgeInsetsGeometry _getDefaultPadding(BuildContext context) {
    if (Responsive.isMobile(context)) {
      return const EdgeInsets.all(16.0);
    } else if (Responsive.isTablet(context)) {
      return const EdgeInsets.all(24.0);
    } else {
      return const EdgeInsets.all(32.0);
    }
  }

  double _getMaxWidth(BuildContext context) {
    if (Responsive.isLargeDesktop(context)) {
      return 1440;
    } else if (Responsive.isDesktop(context)) {
      return 1200;
    } else if (Responsive.isTablet(context)) {
      return 768;
    } else {
      return MediaQuery.of(context).size.width;
    }
  }
}

class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final double spacing;
  final double runSpacing;
  final int? maxCrossAxisCount;
  final double childAspectRatio;
  final bool shrinkWrap;

  const ResponsiveGrid({
    Key? key,
    required this.children,
    this.spacing = 16,
    this.runSpacing = 16,
    this.maxCrossAxisCount,
    this.childAspectRatio = 1,
    this.shrinkWrap = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = _getCrossAxisCount(context, constraints.maxWidth);
        
        return GridView.builder(
          shrinkWrap: shrinkWrap,
          physics: shrinkWrap ? const NeverScrollableScrollPhysics() : null,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: childAspectRatio,
            crossAxisSpacing: spacing,
            mainAxisSpacing: runSpacing,
          ),
          itemCount: children.length,
          itemBuilder: (context, index) => children[index],
        );
      },
    );
  }

  int _getCrossAxisCount(BuildContext context, double width) {
    int count;
    if (Responsive.isLargeDesktop(context)) {
      count = 6;
    } else if (Responsive.isDesktop(context)) {
      count = 4;
    } else if (Responsive.isTablet(context)) {
      count = 3;
    } else {
      count = 2;
    }
    return maxCrossAxisCount != null ? count.clamp(1, maxCrossAxisCount!) : count;
  }
}

class ResponsivePadding extends StatelessWidget {
  final Widget child;

  const ResponsivePadding({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: ResponsiveValue<EdgeInsets>(
        mobile: const EdgeInsets.all(16),
        tablet: const EdgeInsets.all(24),
        desktop: const EdgeInsets.all(32),
        largeDesktop: const EdgeInsets.all(40),
      ).get(context),
      child: child,
    );
  }
}

class ResponsivePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: _buildMobileLayout(),
      // tablet: _buildTabletLayout(), // Convert method to Widget
      desktop: _buildMobileLayout(), // Reuse mobile layout since desktop isn't defined
    );
  }

  Widget _buildMobileLayout() {
    return ResponsiveContainer(
      child: SingleChildScrollView(
        child: Column(
          children: [
            ResponsivePadding(
              child: Container(), // Placeholder widget
            ),
            ResponsiveGrid(
              children: const [], // Empty list as placeholder
            ),
          ],
        ),
      ),
    );
  }
}

class _buildTabletLayout {
}
