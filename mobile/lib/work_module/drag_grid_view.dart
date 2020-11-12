import 'package:flutter/material.dart';
import 'dart:math' as math;

class DragBean {
  DragBean({
    this.index,
    this.selected: false,
  });

  int index;
  bool selected;
}

typedef OnDragListener = bool Function(MotionEvent event, double itemWidth);

typedef OnDragFinishListener = Function(List<DragBean> data);

class MotionEvent {
  static const int actionDown = 0;
  static const int actionUp = 1;
  static const int actionMove = 2;

  int action;

  int dragIndex;

  int nextIndex;

  double globalX;

  double globalY;
}

class DragGridView extends StatefulWidget {
  DragGridView(this.data,
      {Key key,
      this.draggable,
      this.topIndex,
      this.width,
      this.space: 0,
      this.padding: EdgeInsets.zero,
      this.margin: EdgeInsets.zero,
      @required this.itemBuilder,
      this.onDragListener,
      this.onDragFinishListener})
      : assert(data != null),
        assert(itemBuilder != null),
        super(key: key);

  final List<DragBean> data;

  bool draggable = true;

  final double width;

  final double space;

  final int topIndex;

  final EdgeInsets padding;

  final EdgeInsets margin;

  final IndexedWidgetBuilder itemBuilder;

  final OnDragListener onDragListener;

  final OnDragFinishListener onDragFinishListener;

  @override
  State<StatefulWidget> createState() {
    return DragGridViewState();
  }
}

class DragGridViewState extends State<DragGridView>
    with TickerProviderStateMixin {
  AnimationController _controller;

  AnimationController _zoomController;

  AnimationController _floatController;

  List<Rect> _positions = List();

  List<DragBean> _cacheData = List();

  int _dragIndex = -1;

  int nextIndex = -1;

  DragBean _dragBean;

  MotionEvent _motionEvent;

  static OverlayEntry _overlayEntry;

  int _itemCount = 0;

  double _itemWidth = 0;

  Offset _downGlobalPos;
  double _downLeft;
  double _downTop;
  double _floatLeft = 0;
  double _floatTop = 0;
  double _fromTop = 0;
  double _fromLeft = 0;
  double _toTop = 0;
  double _toLeft = 0;

  num crossAxisCount = 5;

  int maxCount = 15;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(duration: Duration(milliseconds: 200), vsync: this);
    _zoomController =
        AnimationController(duration: Duration(milliseconds: 100), vsync: this);
    _floatController =
        AnimationController(duration: Duration(milliseconds: 200), vsync: this);
    _controller.addListener(() {
      setState(() {});
    });
    _zoomController.addListener(() {
      _updateOverlay();
    });
    _floatController.addListener(() {
      _floatLeft =
          _toLeft + (_fromLeft - _toLeft) * (1 - _floatController.value);
      _floatTop = _toTop + (_fromTop - _toTop) * (1 - _floatController.value);
      _updateOverlay();
    });
    _floatController.addStatusListener((AnimationStatus status) {
      if (status == AnimationStatus.completed) {
        _clearAll();
      }
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    _zoomController?.dispose();
    _floatController?.dispose();
    _removeOverlay();
    super.dispose();
  }

  void _init(BuildContext context, EdgeInsets padding, EdgeInsets margin) {
    double space = widget.space;
    double width = widget.width ??
        (MediaQuery.of(context).size.width - margin.left - margin.right);
    width = width - padding.left - padding.right;
    _itemWidth = (width - space * 2) / crossAxisCount;
    _positions.clear();
    for (int i = 0; i < maxCount; i++) {
      double left = (space + _itemWidth) * (i % crossAxisCount);
      double top = (space + _itemWidth * 1.2) * (i ~/ crossAxisCount);
      _positions.add(Rect.fromLTWH(left, top, _itemWidth, _itemWidth * 1.2));
    }
  }

  Offset _getWidgetLocalToGlobal(BuildContext context) {
    RenderBox box = context.findRenderObject();
    return box == null ? Offset.zero : box.localToGlobal(Offset.zero);
  }

  int _getDragIndex(Offset offset) {
    for (int i = 0; i < _itemCount; i++) {
      if (_positions[i].contains(offset)) {
        return i;
      }
    }
    return -1;
  }

  void _initIndex() {
    for (int i = 0; i < _itemCount; i++) {
      widget.data[i].index = i;
    }
    _cacheData.clear();
    _cacheData.addAll(widget.data);
  }

  void _addOverlay(BuildContext context, Widget overlay) {
    OverlayState overlayState = Overlay.of(context);
    double space = widget.space;
    if (_overlayEntry == null) {
      _overlayEntry = OverlayEntry(builder: (BuildContext context) {
        return Positioned(
            left: _floatLeft - space * _zoomController.value,
            top: _floatTop - space * _zoomController.value,
            child: Material(
              child: Container(
                width: _itemWidth + space * _zoomController.value * 2,
                height: _itemWidth * 1.2 + space * _zoomController.value * 2,
                color: Colors.transparent,
                child: overlay,
              ),
            ));
      });
      overlayState.insert(_overlayEntry);
    } else {
      _overlayEntry.markNeedsBuild();
    }
    _zoomController.reset();
    _zoomController.forward();
  }

  void _updateOverlay() {
    if (_overlayEntry != null) {
      _overlayEntry.markNeedsBuild();
    }
  }

  void _removeOverlay() {
    if (_overlayEntry != null) {
      _overlayEntry.remove();
      _overlayEntry = null;
    }
  }

  int _getNextIndex(Rect curRect, Rect origin) {
    if (_itemCount == 1) return 0;
    bool outside = true;
    for (int i = 0; i < _itemCount; i++) {
      Rect rect = _positions[i];
      bool overlaps = rect.overlaps(curRect);
      if (overlaps) {
        outside = false;
        Rect over = rect.intersect(curRect);
        Rect ori = origin.intersect(curRect);
        if (_getRectArea(over) > _itemWidth * _itemWidth / 2 ||
            _getRectArea(over) > _getRectArea(ori)) {
          return i;
        }
      }
    }
    int index = -1;
    if (outside) {
      if (curRect.bottom < 0) {
        index = _checkIndexTop(curRect);
      } else if (curRect.top > _itemWidth) {
        index = _checkIndexBottom(curRect);
      }
    }
    return index;
  }

  double _getRectArea(Rect rect) {
    return rect.width * rect.height;
  }

  int _checkIndexTop(Rect other) {
    int index = -1;
    double area;
    for (int i = 0; (i < crossAxisCount && i < _itemCount); i++) {
      Rect rect = _positions[i];
      Rect over = rect.intersect(other);
      double _area = _getRectArea(over);
      if (area == null || _area <= area) {
        area = _area;
        index = i;
      }
    }
    return index;
  }

  int _checkIndexBottom(Rect other) {
    int tagIndex = -1;
    double area;
    for (int i = 0; (i < crossAxisCount && i < _itemCount); i++) {
      Rect _rect = _positions[i];
      Rect over = _rect.intersect(other);
      double _area = _getRectArea(over);
      if (area == null || _area <= area) {
        area = _area;
        tagIndex = i;
      }
    }
    if (tagIndex != -1) {
      for (int i = _itemCount - 1; i >= 0; i--) {
        if (((i + 1) / crossAxisCount).ceil() >=
                (((_dragIndex + 1) / crossAxisCount).ceil()) &&
            (i % crossAxisCount == tagIndex)) {
          return i;
        }
      }
    }
    return -1;
  }

  void _clearAll() {
    _removeOverlay();
    _cacheData.clear();
    int count = math.min(maxCount, widget.data.length);
    for (int i = 0; i < count; i++) {
      widget.data[i].index = i;
      widget.data[i].selected = false;
    }
    setState(() {});
  }

  bool _triggerDragEvent(int action) {
    if (widget.onDragListener != null && _dragIndex != -1) {
      if (_motionEvent == null) _motionEvent = MotionEvent();
      _motionEvent.dragIndex = _dragIndex;
      _motionEvent.action = action;
      _motionEvent.globalX = _floatLeft;
      _motionEvent.globalY = _floatTop;
      _motionEvent.nextIndex = nextIndex;
      return widget.onDragListener(_motionEvent, _itemWidth);
    }
    return false;
  }

  Widget _buildChild(BuildContext context) {
    List<Widget> children = List();
    if (_cacheData.isEmpty) {
      for (int i = 0; i < _itemCount; i++) {
        children.add(
          Positioned.fromRect(
            rect: _positions[i],
            child: widget.itemBuilder(context, i),
          ),
        );
      }
    } else {
      for (int i = 0; i < _itemCount; i++) {
        int curIndex = widget.data[i].index;
        int lastIndex = _cacheData[i].index;
        double left = _positions[curIndex].left +
            (_positions[lastIndex].left - _positions[curIndex].left) *
                _controller.value;
        double top = _positions[curIndex].top +
            (_positions[lastIndex].top - _positions[curIndex].top) *
                _controller.value;
        children.add(Positioned(
          left: left,
          top: top,
          width: _itemWidth,
          height: _itemWidth * 1.2,
          child: Offstage(
            offstage: widget.data[i].selected == true,
            child: widget.itemBuilder(context, i),
          ),
        ));
      }
    }
    return Stack(
      children: children,
    );
  }

  @override
  Widget build(BuildContext context) {
    _itemCount = math.min(maxCount, widget.data.length);
    EdgeInsets padding = widget.padding;
    EdgeInsets margin = widget.margin;
    if (_itemWidth == 0) {
      _init(context, padding, margin);
    }

    int column =
        (_itemCount > crossAxisCount ? crossAxisCount : _itemCount + 1);
    var row = ((_itemCount) ~/ crossAxisCount) +
        ((_itemCount) % crossAxisCount == 0 ? 0 : 1);

    double realWidth = _itemWidth * column +
        widget.space * (column - 1) +
        padding.left +
        padding.right;
    double realHeight = _itemWidth * 1.2 * row +
        widget.space * (row - 1) +
        padding.top +
        padding.bottom;
    double left = margin.left + padding.left;
    double top = margin.top + padding.top;

    return GestureDetector(
      onLongPressStart: (LongPressStartDetails details) {
        if (!widget.draggable) {
          return;
        }
        Offset offset = _getWidgetLocalToGlobal(context);
        _dragIndex = _getDragIndex(details.localPosition);
        if (_dragIndex == -1) return;
        _initIndex();
        widget.data[_dragIndex].selected = true;
        _dragBean = widget.data[_dragIndex];
        _downGlobalPos = details.globalPosition;
        _downLeft = left + _positions[_dragIndex].left;
        _downTop = top + _positions[_dragIndex].top;
        _toLeft = offset.dx + left + _positions[_dragIndex].left;
        _toTop = offset.dy + top + _positions[_dragIndex].top;
        _floatLeft = _toLeft;
        _floatTop = _toTop;
        Widget overlay = widget.itemBuilder(context, _dragIndex);
        _addOverlay(context, overlay);
        _triggerDragEvent(MotionEvent.actionDown);
        setState(() {});
      },
      onLongPressMoveUpdate: (LongPressMoveUpdateDetails details) {
        if (!widget.draggable) {
          return;
        }
        var dragBean = widget.data[_dragIndex];
        if (_dragIndex == -1) return;

        _floatLeft = _toLeft + (details.globalPosition.dx - _downGlobalPos.dx);
        _floatTop = _toTop + (details.globalPosition.dy - _downGlobalPos.dy);

        double left =
            _downLeft + (details.globalPosition.dx - _downGlobalPos.dx);
        double top = _downTop + (details.globalPosition.dy - _downGlobalPos.dy);
        Rect cRect = Rect.fromLTWH(left, top, _itemWidth, _itemWidth * 1.2);
        nextIndex = _getNextIndex(cRect, _positions[_dragIndex]);
        // debugPrint("nextIndex ="+nextIndex.toString()+"  dragBean.topping = "+dragBean.topping.toString());
        // if (dragBean.topping && nextIndex > widget.topIndex ||
        //     !dragBean.topping && nextIndex <= widget.topIndex) {
        //   debugPrint("nextIndex2 ="+nextIndex.toString());
        // } else
          if (nextIndex != -1 && _dragIndex != nextIndex) {
          _initIndex();
          _dragIndex = nextIndex;
          widget.data.remove(_dragBean);
          widget.data.insert(_dragIndex, _dragBean);
          _controller.reset();
          _controller.forward();
        }
        _updateOverlay();
        _triggerDragEvent(MotionEvent.actionMove);
      },
      onLongPressEnd: (LongPressEndDetails details) {
        if (!widget.draggable) {
          return;
        }
        if (_dragIndex == -1) return;
        _fromLeft = _toLeft + (details.globalPosition.dx - _downGlobalPos.dx);
        _fromTop = _toTop + (details.globalPosition.dy - _downGlobalPos.dy);
        Offset offset = _getWidgetLocalToGlobal(context);
        _toLeft = offset.dx + left + _positions[_dragIndex].left;
        _toTop = offset.dy + top + _positions[_dragIndex].top;
      },
      onLongPressUp: () {
        if (!widget.draggable) {
          return;
        }
        _dragBean = null;
        bool isCatch = _triggerDragEvent(MotionEvent.actionUp);
        if (isCatch) {
          widget.data.removeAt(_dragIndex);
          _clearAll();
          widget.onDragFinishListener(widget.data);
        } else {
          _floatController.reset();
          _floatController.forward();
        }
      },
      child: Container(
        width: realWidth,
        height: realHeight,
        margin: margin,
        padding: padding,
        child: _buildChild(context),
      ),
    );
  }
}
