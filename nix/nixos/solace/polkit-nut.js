polkit.addRule(function (action, subject) {
  if (subject.user == "nut") {
    if (action.id.startsWith("org.freedesktop.login1.power-off")) {
      return polkit.Result.YES;
    }
    if (action.id == "org.freedesktop.policykit.exec"
        && action.lookup("program") == "@notify_prog@"
        && action.lookup("user") == "archit") {
      return polkit.Result.YES;
    }
  }
});
