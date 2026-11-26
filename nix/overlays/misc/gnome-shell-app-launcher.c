// Copyright (C) Archit Gupta <archit@accelbread.com>
// SPDX-License-Identifier: AGPL-3.0-or-later

#include <errno.h>
#include <gio/gdesktopappinfo.h>
#include <string.h>
#include <unistd.h>

// Match gnome_start_systemd_scope(), reserving room for the PID on long names.
static char *
scope_name(const char *name)
{
    g_autofree char *app = NULL;
    g_autofree char *suffix = g_strdup_printf("-%ld.scope", (long)getpid());
    GString *unit = g_string_new("app-gnome-");
    size_t limit = 255 - strlen(suffix);

    if (g_path_is_absolute(name))
        name = app = g_path_get_basename(name);
    else if (g_str_has_suffix(name, ".desktop"))
        name = app = g_strndup(name, strlen(name) - strlen(".desktop"));

    for (; *name; name++) {
        char escaped[16];
        if (g_ascii_isalnum(*name) || strchr(":_.", *name))
            g_snprintf(escaped, sizeof escaped, "%c", *name);
        else
            g_snprintf(escaped, sizeof escaped, "\\x%02hhx", *name);
        if (unit->len + strlen(escaped) > limit)
            break;
        g_string_append(unit, escaped);
    }
    g_string_append(unit, suffix);
    return g_string_free(unit, FALSE);
}

int
main(int argc, char **argv)
{
    g_autoptr(GDesktopAppInfo) info = NULL;
    g_autofree char *unit = NULL;
    const char *name;
    // GIO passes the executable at argv[1]. Shell marks its direct-command
    // invocation explicitly, followed by the original argv[0] and command.
    gboolean direct = argc > 1 && g_str_equal(argv[1], "--command");
    if (argc < (direct ? 4 : 2))
        return 1;

    if (direct) {
        name = argv[2];
        argv += 3;
    } else {
        const char *file = g_getenv("GIO_LAUNCHED_DESKTOP_FILE");
        if (file)
            info = g_desktop_app_info_new_from_filename(file);
        name = info ? g_app_info_get_id(G_APP_INFO(info)) : NULL;
        if (!name)
            name = argv[1];
        argv[0] = GIO_LAUNCH_DESKTOP;
        g_unsetenv("GIO_LAUNCH_DESKTOP");
    }

    unit = scope_name(name);
    const char *options[] = {
        SYSTEMD_RUN, "--user", "--scope", "--quiet", "--no-ask-password",
        "--collect", "--job-mode=fail", "--expand-environment=no",
        "--slice=app.slice", "--unit", unit, "--",
    };
    g_autofree char **command =
        g_new(char *, G_N_ELEMENTS(options) + g_strv_length(argv) + 1);
    memcpy(command, options, sizeof options);
    memcpy(command + G_N_ELEMENTS(options), argv,
           (g_strv_length(argv) + 1) * sizeof *argv);
    execv(SYSTEMD_RUN, command);
    g_printerr("Failed to execute systemd-run: %s\n", g_strerror(errno));
    return 1;
}
