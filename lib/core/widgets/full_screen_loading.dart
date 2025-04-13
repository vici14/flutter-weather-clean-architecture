import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class FullScreenLoading extends StatelessWidget {
  const FullScreenLoading({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.appBackground,
      width: double.infinity,
      height: double.infinity,
      child: const Center(
        child: RotatingImage(),
      ),
    );
  }
}

class RotatingImage extends StatefulWidget {
  const RotatingImage({Key? key}) : super(key: key);

  @override
  State<RotatingImage> createState() => _RotatingImageState();
}

class _RotatingImageState extends State<RotatingImage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        return Transform.rotate(
          angle: _controller.value * 2 * 3.14159,
          child: const Image(
            image: AssetImage('assets/icons/ic_loading.png'),
            width: 96,
            height: 96,
          ),
        );
      },
    );
  }
}

//3rd solution
// import 'package:flutter/material.dart';
// import '../theme/app_colors.dart';

// class FullScreenLoading extends StatelessWidget {
//   const FullScreenLoading({
//     Key? key,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       color: AppColors.appBackground,
//       width: double.infinity,
//       height: double.infinity,
//       child: const Center(
//         child: ContinuousRotation(),
//       ),
//     );
//   }
// }

// class ContinuousRotation extends StatelessWidget {
//   const ContinuousRotation({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return TweenAnimationBuilder<double>(
//       tween: Tween<double>(begin: 0, end: 2 * 3.14159),
//       duration: const Duration(seconds: 1),
//       onEnd: () => {},
//       builder: (_, angle, child) {
//         return Transform.rotate(
//           angle: angle,
//           child: child,
//         );
//       },
//       child: const Image(
//         image: AssetImage('assets/icons/ic_loading.png'),
//         width: 80,
//         height: 80,
//       ),
//     );
//   }
// }
