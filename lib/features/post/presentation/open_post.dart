import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';

/// Opens the outfit post screen on top of the current one.
void openPost(BuildContext context, String postId) =>
    context.push(AppRoutes.post(postId));
