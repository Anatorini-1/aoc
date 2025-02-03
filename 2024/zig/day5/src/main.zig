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

    var rule_buffer: [2][]const u8 = undefined;
    var new_rule_ptr: *rule = undefined;
    var result_part1: u32 = 0;
    var result_part2: u32 = 0;

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
                const r = try part1(line_buffer.slice(), rules.slice());
                result_part1 += r;
                if (r == 0) {
                    result_part2 += try part2(line_buffer.slice(), rules.slice());
                }
            },
        }

        line_buffer.clear();
    }
    std.debug.print("Part 1: {}\n", .{result_part1});
    std.debug.print("Part 2: {}\n", .{result_part2});
}

fn part2(line: []u8, rules: []rule) !u32 {
    var printed = try std.BoundedArray(u32, 1000).init(0);
    var pages = try std.BoundedArray(u32, 1000).init(0);
    var iter = std.mem.splitSequence(u8, line, ",");
    var current_page: u32 = undefined;
    while (iter.next()) |page| {
        current_page = try std.fmt.parseInt(u32, page, 10);
        try pages.append(current_page);
    }
    var i: u32 = 0;
    while (i < pages.len) {
        if (pages.get(i) == 0) {
            i += 1;
            continue;
        }
        if (isValid(rules, pages.slice(), printed.slice(), pages.get(i))) {
            try printed.append(pages.get(i));
            pages.set(i, 0);
            i = 0;
        } else {
            i += 1;
        }
    }
    return printed.get(printed.len / 2);
}
fn part1(line: []u8, rules: []rule) !u32 {
    var current_page: u32 = undefined;
    var iter = std.mem.splitSequence(u8, line, ",");
    var pages = try std.BoundedArray(u32, 1000).init(0);
    var printed = try std.BoundedArray(u32, 1000).init(0);

    while (iter.next()) |page| {
        current_page = try std.fmt.parseInt(u32, page, 10);
        try pages.append(current_page);
    }
    var valid: bool = true;
    for (pages.slice()) |p| {
        if (isValid(rules, pages.slice(), printed.slice(), p) == false) {
            valid = false;
            break;
        }
        try printed.append(p);
    }
    if (valid) {
        return pages.get(pages.len / 2);
    } else {
        return 0;
    }
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
