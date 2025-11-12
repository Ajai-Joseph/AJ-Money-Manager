import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:aj_money_manager/models/category_model.dart';
import 'package:aj_money_manager/models/transaction_model.dart';
import 'package:aj_money_manager/config/theme/app_theme.dart';
import 'package:aj_money_manager/screens/home/screen_home.dart';
import 'package:aj_money_manager/screens/search/search_screen.dart';
import 'package:aj_money_manager/screens/monthly_wise_transaction.dart';
import 'package:aj_money_manager/screens/category/add_edit_category_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  if (!Hive.isAdapterRegistered(CategoryModelAdapter().typeId)) {
    Hive.registerAdapter(CategoryModelAdapter());
  }
  if (!Hive.isAdapterRegistered(TransactionModelAdapter().typeId)) {
    Hive.registerAdapter(TransactionModelAdapter());
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ScreenHome.themeModeNotifier,
      builder: (context, themeMode, _) {
        return MaterialApp(
          title: 'AJ Money Manager',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeMode,
          debugShowCheckedModeBanner: false,
          home: const ScreenHome(),
          routes: {
            '/search': (context) => const SearchScreen(),
            '/monthly-transactions': (context) => const MonthlyWiseTransaction(),
            '/add-category': (context) => const AddEditCategoryScreen(),
          },
          onGenerateRoute: (settings) {
            // Custom page transitions for all routes
            return _createRoute(settings);
          },
        );
      },
    );
  }

  // Create custom page transitions
  static Route<dynamic>? _createRoute(RouteSettings settings) {
    Widget page;
    
    switch (settings.name) {
      case '/search':
        page = const SearchScreen();
        break;
      case '/monthly-transactions':
        page = const MonthlyWiseTransaction();
        break;
      case '/add-category':
        page = const AddEditCategoryScreen();
        break;
      default:
        return null;
    }

    // Use fade + slide transition for all routes
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 0.05);
        const end = Offset.zero;
        const curve = Curves.easeInOut;

        var tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );

        var offsetAnimation = animation.drive(tween);
        var fadeAnimation = CurvedAnimation(
          parent: animation,
          curve: curve,
        );

        return FadeTransition(
          opacity: fadeAnimation,
          child: SlideTransition(
            position: offsetAnimation,
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }
}

// Helper class for creating custom page transitions
class CustomPageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  final RouteTransitionType transitionType;

  CustomPageRoute({
    required this.page,
    this.transitionType = RouteTransitionType.fadeSlide,
    super.settings,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return _buildTransition(
              transitionType,
              animation,
              secondaryAnimation,
              child,
            );
          },
          transitionDuration: const Duration(milliseconds: 300),
        );

  static Widget _buildTransition(
    RouteTransitionType type,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    switch (type) {
      case RouteTransitionType.fade:
        return FadeTransition(
          opacity: animation,
          child: child,
        );

      case RouteTransitionType.slide:
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;
        var tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );
        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );

      case RouteTransitionType.fadeSlide:
        const begin = Offset(0.0, 0.05);
        const end = Offset.zero;
        const curve = Curves.easeInOut;
        var tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );
        return FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: curve),
          child: SlideTransition(
            position: animation.drive(tween),
            child: child,
          ),
        );

      case RouteTransitionType.scale:
        return ScaleTransition(
          scale: Tween<double>(begin: 0.9, end: 1.0).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeInOut),
          ),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
    }
  }
}

// Enum for different transition types
enum RouteTransitionType {
  fade,
  slide,
  fadeSlide,
  scale,
}
