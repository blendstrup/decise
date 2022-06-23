import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

// Adapted from: https://github.com/davidanaya/flutter-spinning-wheel

/// Returns a widget which displays a rotating widget.
/// This widget can be interacted with with drag gestures.

class SpinningWheel extends StatefulWidget {
  /// width used by the container with the child
  final double width;

  /// height used by the container with the child
  final double height;

  /// widget that will be used as wheel
  final Widget child;

  // widget that will be used as an indicator at the top of the wheel
  final Widget indicator;

  /// number of equal divisions in the wheel
  final int dividers;

  /// initial rotation angle from 0.0 to 2*pi
  /// default is 0.0
  final double initialSpinAngle;

  /// has to be higher than 0.0 (no resistance) and lower or equal to 1.0
  /// default is 0.5
  final double spinResistance;

  /// if true, the user can interact with the wheel while it spins
  /// default is true
  final bool canInteractWhileSpinning;

  /// callback function to be executed when the wheel selection changes
  final Function onUpdate;

  /// callback function to be executed when the animation stops
  final Function onEnd;

  /// Stream<double> used to trigger an animation
  /// if triggered in an animation it will stop it, unless canInteractWhileSpinning is false
  /// the parameter is a double for pixelsPerSecond in axis Y, which defaults to 8000.0 as a medium-high velocity
  final Stream<double>? shouldStartOrStop;

  const SpinningWheel({
    required this.child,
    required this.indicator,
    required this.width,
    required this.height,
    required this.dividers,
    this.initialSpinAngle = 0.0,
    this.spinResistance = 0.5,
    this.canInteractWhileSpinning = true,
    required this.onUpdate,
    required this.onEnd,
    this.shouldStartOrStop,
  })  : assert(width > 0.0 && height > 0.0),
        assert(spinResistance > 0.0 && spinResistance <= 1.0),
        assert(initialSpinAngle >= 0.0 && initialSpinAngle <= (2 * pi));

  @override
  _SpinningWheelState createState() => _SpinningWheelState();
}

class _SpinningWheelState extends State<SpinningWheel>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  // we need to store if has the widget behaves differently depending on the status
  //AnimationStatus _animationStatus = AnimationStatus.dismissed;

  // it helps calculating the velocity based on position and pixels per second velocity and angle
  late SpinVelocity _spinVelocity;
  late NonUniformCircularMotion _motion;

  // keeps the last local position on pan update
  // we need it onPanEnd to calculate in which cuadrant the user was when last dragged
  Offset? _localPositionOnPanUpdate;

  // duration of the animation based on the initial velocity
  double _totalDuration = 0;

  // initial velocity for the wheel when the user spins the wheel
  double _initialCircularVelocity = 0;

  // angle for each divider: 2*pi / numberOfDividers
  late double _dividerAngle;

  // current (circular) distance (angle) covered during the animation
  double _currentDistance = 0;

  // initial spin angle when the wheels starts the animation
  late double _initialSpinAngle;

  // dividider which is selected (positive y-coord)
  late int _currentDivider;

  // spining backwards
  late bool _isBackwards;

  // if the user drags outside the wheel, won't be able to get back in
  DateTime? _offsetOutsideTimestamp;

  // will be used to do transformations between global and local
  RenderBox? _renderBox;

  // subscription to the stream used to trigger an animation
  StreamSubscription? _subscription;

  @override
  void initState() {
    super.initState();

    _spinVelocity = SpinVelocity(width: widget.width, height: widget.height);
    _motion = NonUniformCircularMotion(resistance: widget.spinResistance);

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 0),
    );
    _animation = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.linear,
    ));

    _dividerAngle = _motion.anglePerDivision(widget.dividers);
    _initialSpinAngle = widget.initialSpinAngle;

    _animation.addStatusListener((status) {
      //_animationStatus = status;
      if (status == AnimationStatus.completed) _stopAnimation();
    });

    if (widget.shouldStartOrStop != null) {
      _subscription = widget.shouldStartOrStop!.listen(_startOrStop);
    }
  }

  void _startOrStop(double? velocity) {
    //if (_animationController.isAnimating) {
    //  _stopAnimation();
    //} else {

    // velocity is pixels per second in axis Y
    // we asume a drag from cuadrant 1 with high velocity (8000)
    double pixelsPerSecondY = velocity ?? 8000.0;
    _localPositionOnPanUpdate = const Offset(250.0, 250.0);
    _startAnimation(Offset(0.0, pixelsPerSecondY));

    //}
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      width: widget.width,
      child: Stack(
        children: [
          GestureDetector(
            onPanUpdate: _moveWheel,
            onPanEnd: _startAnimationOnPanEnd,
            onPanDown: (_details) => _stopAnimation(),
            child: AnimatedBuilder(
                animation: _animation,
                child: Container(child: widget.child),
                builder: (context, child) {
                  _updateAnimationValues();
                  widget.onUpdate(_currentDivider);
                  return Transform.rotate(
                    angle: _initialSpinAngle + _currentDistance,
                    child: child,
                  );
                }),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: widget.indicator,
          ),
        ],
      ),
    );
  }

  // user can interact only if widget allows or wheel is not spinning
  bool get _userCanInteract =>
      !_animationController.isAnimating || widget.canInteractWhileSpinning;

  // transforms from global coordinates to local and store the value
  void _updateLocalPosition(Offset position) {
    _renderBox ??= context.findRenderObject() as RenderBox;

    _localPositionOnPanUpdate = _renderBox!.globalToLocal(position);
  }

  /// returns true if (x,y) is outside the boundaries from size
  bool _contains(Offset p) => Size(widget.width, widget.height).contains(p);

  // this is called just before the animation starts
  void _updateAnimationValues() {
    if (_animationController.isAnimating) {
      // calculate total distance covered
      double currentTime = _totalDuration * _animation.value;
      _currentDistance =
          _motion.distance(_initialCircularVelocity, currentTime);
      if (_isBackwards) {
        _currentDistance = -_currentDistance;
      }
    }
    // calculate current divider selected
    double modulo = _motion.modulo(_currentDistance + _initialSpinAngle);
    _currentDivider = widget.dividers - (modulo ~/ _dividerAngle);
    if (_animationController.isCompleted) {
      _initialSpinAngle = modulo;
      _currentDistance = 0;
    }
  }

  void _moveWheel(DragUpdateDetails details) {
    if (!_userCanInteract) return;

    // user won't be able to get back in after dragin outside
    if (_offsetOutsideTimestamp != null) return;

    _updateLocalPosition(details.globalPosition);

    if (_contains(_localPositionOnPanUpdate as Offset)) {
      // we need to update the rotation
      // so, calculate the new rotation angle and rebuild the widget
      double angle =
          _spinVelocity.offsetToRadians(_localPositionOnPanUpdate as Offset);
      setState(() {
        // initialSpinAngle will be added later on build
        _currentDistance = angle - _initialSpinAngle;
      });
    } else {
      // if user dragged outside the boundaries we save the timestamp
      // when user releases the drag, it will trigger animation only if less than duration time passed from now
      _offsetOutsideTimestamp = DateTime.now();
    }
  }

  void _stopAnimation() {
    if (!_userCanInteract) return;

    _offsetOutsideTimestamp = null;
    _animationController.stop();
    _animationController.reset();

    widget.onEnd(_currentDivider);
  }

  void _startAnimationOnPanEnd(DragEndDetails details) {
    if (!_userCanInteract) return;

    if (_offsetOutsideTimestamp != null) {
      Duration difference =
          DateTime.now().difference(_offsetOutsideTimestamp ?? DateTime.now());
      _offsetOutsideTimestamp = null;
      // if more than 50 milliseconds passed since user dragged outside the boundaries, dont start animation
      if (difference.inMilliseconds > 50) return;
    }

    // it was the user just taping to stop the animation
    if (_localPositionOnPanUpdate == null) return;

    _startAnimation(details.velocity.pixelsPerSecond);
  }

  void _startAnimation(Offset pixelsPerSecond) {
    double velocity = _spinVelocity.getVelocity(
      _localPositionOnPanUpdate as Offset,
      pixelsPerSecond,
    );

    _localPositionOnPanUpdate = null;
    _isBackwards = velocity < 0;
    _initialCircularVelocity = pixelsPerSecondToRadians(velocity.abs());
    _totalDuration = _motion.duration(_initialCircularVelocity);

    _animationController.duration =
        Duration(milliseconds: (_totalDuration * 1000).round());

    _animationController.reset();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _subscription?.cancel();
    super.dispose();
  }
}

// Utils
const Map<int, Offset> cuadrants = {
  1: Offset(0.5, 0.5),
  2: Offset(-0.5, 0.5),
  3: Offset(-0.5, -0.5),
  4: Offset(0.5, -0.5),
};

const pi_0_5 = pi * 0.5;
const pi_2_5 = pi * 2.5;
const pi_2 = pi * 2;

class SpinVelocity {
  final double height;
  final double width;

  double get width_0_5 => width / 2;
  double get height_0_5 => height / 2;

  SpinVelocity({required this.height, required this.width});

  double getVelocity(Offset position, Offset pps) {
    int cuadrantIndex = _getCuadrantFromOffset(position);
    Offset? cuadrant = cuadrants[cuadrantIndex];
    return (cuadrant!.dx * pps.dx) + (cuadrant.dy * pps.dy);
  }

  /// transforms (x,y) into radians assuming we start at positive y axis as 0
  double offsetToRadians(Offset position) {
    double a = position.dx - width_0_5;
    double b = height_0_5 - position.dy;
    double angle = atan2(b, a);
    return _normalizeAngle(angle);
  }

  int _getCuadrantFromOffset(Offset p) => p.dx > width_0_5
      ? (p.dy > height_0_5 ? 2 : 1)
      : (p.dy > height_0_5 ? 3 : 4);

  // radians go from 0 to pi (positive y axis) and 0 to -pi (negative y axis)
  // we need radians from positive y axis (0) clockwise back to y axis (2pi)
  double _normalizeAngle(double angle) => angle > 0
      ? (angle > pi_0_5 ? (pi_2_5 - angle) : (pi_0_5 - angle))
      : pi_0_5 - angle;

  bool contains(Offset p) => Size(width, height).contains(p);
}

class NonUniformCircularMotion {
  final double resistance;

  NonUniformCircularMotion({required this.resistance});

  /// returns the acceleration based on the resistance provided in the constructor
  double get acceleration => resistance * -7 * pi;

  /// distance covered in a specified time with initial velocity
  /// 𝜑=𝜑0+𝜔·𝑡+1/2·𝛼·𝑡2
  double distance(double velocity, double time) =>
      (velocity * time) + (0.5 * acceleration * pow(time, 2));

  /// movement duration with initial velocity
  double duration(double velocity) => -velocity / acceleration;

  /// modulo in a circunference
  double modulo(double angle) => angle % (2 * pi);

  /// angle per division in a circunference with x dividers
  double anglePerDivision(int dividers) => (2 * pi) / dividers;
}

/// transforms pixels per second as used by Flutter to radians
/// this is a custom interpreation, it could be updated to adjust the velocity
double pixelsPerSecondToRadians(double pps) {
  // 100 ppx will equal 2pi radians
  return (pps * 2 * pi) / 1000;
}
