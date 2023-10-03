const std = @import("std");
const win = std.os.windows;
const user32 = win.user32;

fn windowCallback(hwnd: win.HWND, umessage: win.UINT, wparam: win.WPARAM, lparam: win.LPARAM) callconv(.C) win.LRESULT {
    switch (umessage) {
        user32.WM_DESTROY => {
            user32.postQuitMessage(0);
            return 0;
        },
        user32.WM_CHAR => {
            std.log.info("Char pressed: {d}", .{wparam});
        },
        user32.WM_MOUSEACTIVATE => {
            std.log.info("Window activated", .{});
        },
        user32.WM_MOUSEMOVE => {
            const x: i32 = @intCast(lparam & @as(isize, 0xfff));
            const y: i32 = @intCast((lparam >> 16) & @as(isize, 0xffff));
            std.log.info("Mouse: {d} x {d}", .{ x, y });
        },
        user32.WM_SIZE => {
            std.log.info("Window resizing", .{});
        },
        else => return user32.defWindowProcA(hwnd, umessage, wparam, lparam),
    }
    return 0;
}

pub fn wWinMain(hinstance: win.HINSTANCE, prev_instance: ?win.HINSTANCE, cmd_line: win.PWSTR, cmd_show_count: win.INT) win.INT {
    _ = cmd_line;
    _ = prev_instance;

    const class_name: [:0]const u8 = "Sample Window Class";

    const wc = user32.WNDCLASSEXA{
        .lpfnWndProc = windowCallback,
        .hInstance = hinstance,
        .lpszClassName = class_name,
        .hIcon = null,
        .hCursor = null,
        .hbrBackground = null,
        .lpszMenuName = null,
        .hIconSm = null,
        .style = 0,
    };

    const class_atom: win.ATOM = user32.RegisterClassExA(&wc);
    _ = class_atom;

    const hwnd: win.HWND = user32.createWindowExA(
        0,
        class_name,
        "Learn to program Windows",
        user32.WS_OVERLAPPEDWINDOW,
        user32.CW_USEDEFAULT,
        user32.CW_USEDEFAULT,
        user32.CW_USEDEFAULT,
        user32.CW_USEDEFAULT,
        null,
        null,
        hinstance,
        null,
    ) catch |err| {
        std.log.err("Failed to create window. Error: {}", .{err});
        return 1;
    };

    _ = user32.showWindow(hwnd, cmd_show_count);

    var message: user32.MSG = undefined;

    while (true) {
        user32.getMessageA(&message, null, 0, 0) catch |err| {
            if (err == error.Quit) {
                return 0;
            }
            std.log.err("Failed to get message. Error: {}", .{err});
            return 1;
        };
        _ = user32.translateMessage(&message);
        _ = user32.dispatchMessageA(&message);
    }

    return 0;
}
