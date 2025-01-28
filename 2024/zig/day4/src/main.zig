const std = @import("std");

const pos = struct { x: usize, y: usize };

const horizontal = enum { left, right, ignore };
const vertical = enum { up, down, ignore };

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const alloc = gpa.allocator();
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

    var buffer = std.ArrayList(u8).init(alloc);
    const writer = buffer.writer();
    const reader = file.reader();
    var data: [150][]u8 = undefined;
    var line: usize = 0;
    var rval: u32 = 0;
    while (true) {
        reader.streamUntilDelimiter(writer, '\n', null) catch |e| switch (e) {
            error.EndOfStream => break,
            error.StreamTooLong => {
                std.debug.print("Line to long", .{});
                return;
            },
            else => unreachable,
        };
        if (buffer.items.len < 3) continue;
        data[line] = try alloc.alloc(u8, buffer.items.len);
        std.mem.copyForwards(u8, data[line], buffer.items);
        line += 1;
        buffer.clearRetainingCapacity();
    }

    for (0..line) |row| {
        for (0..data[row].len) |col| {
            if (data[row][col] == 'X') {
                rval += explore_around(data[0..line], .{ .x = col, .y = row });
            }
        }
    }
    std.debug.print("Part 1: {}\n", .{rval});

    for (0..line) |row| {
        alloc.free(data[row]);
    }
    buffer.deinit();
    _ = gpa.deinit();
}

const pattern = [_]u8{ 'X', 'M', 'A', 'S' };

fn explore_direction(data: [][]u8, start: pos, h: horizontal, v: vertical) u32 {
    var col: usize = undefined;
    var row: usize = undefined;
    for (1..4) |i| {
        col = switch (h) {
            .left => start.x - i,
            .right => start.x + i,
            .ignore => start.x,
        };
        row = switch (v) {
            .up => start.y - i,
            .down => start.y + i,
            .ignore => start.y,
        };
        if (data[row][col] != pattern[i]) return 0;
    }
    return 1;
}

fn explore_around(data: [][]u8, start: pos) u32 {
    var rval: u32 = 0;
    if (start.x >= 3) {
        if (start.y >= 3) {
            rval += explore_direction(data, start, .left, .up);
        }
        if (start.y + 3 < data.len) {
            rval += explore_direction(data, start, .left, .down);
        }
        rval += explore_direction(data, start, .left, .ignore);
    }
    if (start.x + 3 < data[0].len) {
        if (start.y >= 3) {
            rval += explore_direction(data, start, .right, .up);
        }
        if (start.y + 3 < data.len) {
            rval += explore_direction(data, start, .right, .down);
        }
        rval += explore_direction(data, start, .right, .ignore);
    }
    if (start.y >= 3) {
        rval += explore_direction(data, start, .ignore, .up);
    }
    if (start.y + 3 < data.len) {
        rval += explore_direction(data, start, .ignore, .down);
    }
    return rval;
}

test "test" {
    for (1..3) |i| {
        std.debug.print("{}", .{i});
    }
}
