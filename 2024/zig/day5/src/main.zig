const std = @import("std");
const readState = enum { rules, pages };

const rule = struct { X: u32, Y: u32 };

pub fn main() !void {
    var args = std.process.args();
    _ = args.skip();
    const filename = args.next() orelse {
        std.debug.print("Filename missing", .{});
        return;
    };
    const file = std.fs.cwd().openFile(filename, .{}) catch {
        std.debug.print("Failed to open a file", .{});
        return;
    };
    defer file.close();

    var line_buffer = try std.BoundedArray(u8, 1024).init(0);
    const reader = file.reader();
    const writer = line_buffer.writer();
    var state: readState = .rules;

    var rules = try std.BoundedArray(rule, 2048).init(0);
    var pages = try std.BoundedArray(u32, 256).init(0);
    var printed = try std.BoundedArray(u32, 256).init(0);

    var rule_buffer: [2][]const u8 = undefined;
    var new_rule_ptr: *rule = undefined;
    var current_page: u32 = undefined;

    var result: u32 = 0;

    while (true) {
        reader.streamUntilDelimiter(writer, '\n', 100) catch |err| switch (err) {
            error.EndOfStream => break,
            error.StreamTooLong => {
                std.debug.print("Line to long", .{});
                return;
            },
            else => unreachable,
        };

        switch (state) {
            .rules => {
                if (line_buffer.slice().len == 0) {
                    state = .pages;
                    continue;
                }
                var iter = std.mem.splitSequence(u8, line_buffer.slice(), "|");
                if (iter.next()) |val| {
                    rule_buffer[0] = val;
                } else {
                    return error.IllegalFormat;
                }
                if (iter.next()) |val| {
                    rule_buffer[1] = val;
                } else {
                    return error.IllegalFormat;
                }
                new_rule_ptr = rules.addOne() catch |err| switch (err) {
                    error.Overflow => {
                        unreachable;
                    },
                };
                new_rule_ptr.X = try std.fmt.parseInt(u32, rule_buffer[0], 10);
                new_rule_ptr.Y = try std.fmt.parseInt(u32, rule_buffer[1], 10);
            },
            .pages => {
                if (line_buffer.slice().len == 0) {
                    break;
                }

                var iter = std.mem.splitSequence(u8, line_buffer.slice(), ",");
                while (iter.next()) |page| {
                    current_page = try std.fmt.parseInt(u32, page, 10);
                    try pages.append(current_page);
                }
                var valid: bool = true;
                for (pages.slice()) |p| {
                    if (isValid(rules.slice(), pages.slice(), printed.slice(), p) == false) {
                        valid = false;
                        break;
                    }
                    try printed.append(p);
                }
                if (valid) {
                    result += pages.slice()[pages.slice().len / 2];
                } else {}

                pages.clear();
                printed.clear();
            },
        }

        line_buffer.clear();
    }
    std.debug.print("{}\n", .{result});
}

fn inSlice(comptime T: type, haystack: []const T, needle: T) bool {
    for (haystack) |val| {
        if (val == needle) {
            return true;
        }
    }
    return false;
}

fn isValid(rules: []rule, pages: []u32, printed: []u32, page: u32) bool {
    for (rules) |r| {
        if (r.Y == page) {
            if (inSlice(u32, pages, r.X)) {
                if (inSlice(u32, printed, r.X) == false) {
                    return false;
                }
            }
        }
    }
    return true;
}
