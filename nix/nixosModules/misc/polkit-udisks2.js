polkit.addRule(function (action, subject) {
  if (action.id.startsWith("org.freedesktop.udisks2.filesystem-mount")) {
    return polkit.Result.NO;
  }
});
