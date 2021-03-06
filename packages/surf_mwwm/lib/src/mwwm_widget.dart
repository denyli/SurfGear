// Copyright (c) 2019-present,  SurfStudio LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'package:flutter/widgets.dart';
import 'package:surf_injector/surf_injector.dart';
import 'package:mwwm/mwwm.dart';

typedef DependenciesBuilder<C> = C Function(BuildContext);
typedef WidgetStateBuilder = State Function();

/// Base class for widgets that has [WidgetModel]
/// and has dependencies in [Component]
abstract class MwwmWidget<C extends Component> extends StatefulWidget {
  /// A function that build dependencies for WidgetModel and Widget
  final DependenciesBuilder<C> dependenciesBuilder;

  /// Builder for [WidgetState]
  final WidgetStateBuilder widgetStateBuilder;

  /// Builder for [WidgetModel].
  /// Typically is null because
  /// WidgetModelBuilders set in the [WidgetModelFactory]
  final WidgetModelBuilder widgetModelBuilder;

  MwwmWidget({
    Key key,
    @required this.dependenciesBuilder,
    @required this.widgetStateBuilder,
    this.widgetModelBuilder,
  }) : super(
          key: key,
        );

  @override
  _MwwmWidgetState createState() => _MwwmWidgetState<C>();
}

/// Hidden widget that create [WidgetState]
/// It's only proxy builder for [State]
class _ProxyMwwmWidget extends CoreMwwmWidget {
  final WidgetStateBuilder _wsBuilder;

  const _ProxyMwwmWidget({
    Key key,
    WidgetStateBuilder widgetStateBuilder,
    WidgetModelBuilder widgetModelBuilder,
  })  : _wsBuilder = widgetStateBuilder,
        super(
          key: key,
          widgetModelBuilder: widgetModelBuilder,
        );

  @override
  State<StatefulWidget> createState() => _wsBuilder();
}

/// Hold child widget
class _MwwmWidgetState<C extends Component> extends State<MwwmWidget> {
  Widget child;

  @override
  void initState() {
    super.initState();

    child = Injector<C>(
      component: widget.dependenciesBuilder(context),
      builder: (ctx) => _ProxyMwwmWidget(
        widgetStateBuilder: widget.widgetStateBuilder,
        widgetModelBuilder: widget.widgetModelBuilder,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return child;
  }
}

/// Implementation of MwwmWidget based on [InheritedWidget]
/// todo test perfomance
abstract class MwwmInheritedWidget<C extends Component>
    extends InheritedWidget {
  MwwmInheritedWidget({
    @required DependenciesBuilder<C> dependenciesBuilder,
    @required WidgetStateBuilder widgetStateBuilder,
    WidgetModelBuilder widgetModelBuilder,
  }) : super(
          child: Builder(
            builder: (context) => Injector<C>(
              component: dependenciesBuilder(context),
              builder: (ctx) {
                return _ProxyMwwmWidget(
                  widgetStateBuilder: widgetStateBuilder,
                  widgetModelBuilder: widgetModelBuilder,
                );
              },
            ),
          ),
        );

  /// Yet this forever true because otherwise hot reload not working.
  @override
  bool updateShouldNotify(InheritedWidget oldWidget) {
    return true;
  }
}
