// Copyright (C) Archit Gupta <archit@accelbread.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
polkit.addRule(function (action, subject) {
  if (action.id.startsWith("org.freedesktop.udisks2.filesystem-mount")) {
    return polkit.Result.NO;
  }
});
