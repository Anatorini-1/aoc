const std = @import("std");
const readState = enum { rules, pages };

const DIRECTION = enum { UP, DOWN, LEFT, RIGHT };
const Position = struct { x: usize, y: usize };
const Guard = struct { pos: Position, dir: DIRECTION };

const Map = struct {
    buffer: std.ArrayList([]u8),
    alloc: std.mem.Allocator,
    fn addRow(self: *Map, data: []u8) !void {
        const current_line = try self.alloc.alloc(u8, data.len);
        try self.buffer.append(current_line);
        std.mem.copyForwards(u8, current_line, data);
    }
    fn rows(self: *Map) usize {
        return self.buffer.items.len;
    }
    fn cols(self: *Map) usize {
        if (self.buffer.items.len == 0) return 0;
        return self.buffer.items[0].len;
    }
    fn get(self: *Map, pos: Position) !u8 {
        if (self.cols() <= pos.x) return error.IndexOutOfRange;
        if (self.rows() <= pos.y) return error.IndexOutOfRange;

        return self.buffer.items[pos.y][pos.x];
    }
    fn set(self: *Map, pos: Position, val: u8) !void {
        if (self.cols() <= pos.x) return error.IndexOutOfRange;
        if (self.rows() <= pos.y) return error.IndexOutOfRange;
        self.buffer.items[pos.y][pos.x] = val;
    }
    fn getGuard(self: *Map) !Guard {
        var current: u8 = undefined;
        for (0..self.rows()) |row| {
            for (0..self.cols()) |col| {
                current = try self.get(Position{ .x = col, .y = row });
                switch (current) {
                    '^' => {
                        return Guard{ .dir = .UP, .pos = .{ .x = col, .y = row } };
                    },
                    'v' => {
                        return Guard{ .dir = .DOWN, .pos = .{ .x = col, .y = row } };
                    },
                    '>' => {
                        return Guard{ .dir = .RIGHT, .pos = .{ .x = col, .y = row } };
                    },
                    '<' => {
                        return Guard{ .dir = .LEFT, .pos = .{ .x = col, .y = row } };
                    },
                    else => {},
                }
            }
        }
        return error.GuardNotFound;
    }
    fn print(self: *Map) void {
        for (self.buffer.items) |row| {
            std.debug.print("{s}\n", .{row});
        }
    }
    fn score(self: *Map) u32 {
        var res: u32 = 0;
        for (self.buffer.items) |row| {
            for (row) |field| {
                switch (field) {
                    '.' => {},
                    '#' => {},
                    else => {
                        res += 1;
                    },
                }
            }
        }

        return res;
    }
};

pub fn main() !void {
    var args = std.process.args();
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const alloc = gpa.allocator();
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

    var line_buffer = std.ArrayList(u8).init(alloc);
    defer line_buffer.deinit();
    const reader = file.reader();
    const writer = line_buffer.writer();
    var map_buffer = std.ArrayList([]u8).init(alloc);
    var map = Map{ .buffer = map_buffer, .alloc = alloc };
    defer map_buffer.deinit();

    while (true) {
        reader.streamUntilDelimiter(writer, '\n', 256) catch |err| switch (err) {
            error.EndOfStream => break,
            error.StreamTooLong => {
                std.debug.print("Line to long", .{});
                return;
            },
            else => unreachable,
        };
        try map.addRow(line_buffer.items);

        line_buffer.clearRetainingCapacity();
    }

    while (true) {
        map = tick(map) catch {
            break;
        };
    }
    std.debug.print("{}\n", .{map.score()});
    for (map.buffer.items) |row| {
        alloc.free(row);
    }
}

fn tick(oldMap: Map) !Map {
    var map: Map = Map{ .alloc = oldMap.alloc, .buffer = oldMap.buffer };
    var guard = try map.getGuard();
    while (true) {
        switch (guard.dir) {
            .DOWN => {
                if (guard.pos.y + 1 == map.rows()) return error.IndexOutOfRange;
                if (try map.get(.{ .x = guard.pos.x, .y = guard.pos.y + 1 }) == '#') {
                    guard.dir = .LEFT;
                } else {
                    break;
                }
            },
            .UP => {
                if (guard.pos.y == 0) return error.IndexOutOfRange;
                if (try map.get(.{ .x = guard.pos.x, .y = guard.pos.y - 1 }) == '#') {
                    guard.dir = .RIGHT;
                } else {
                    break;
                }
            },
            .LEFT => {
                if (guard.pos.x == 0) return error.IndexOutOfRange;
                if (try map.get(.{ .x = guard.pos.x - 1, .y = guard.pos.y }) == '#') {
                    guard.dir = .UP;
                } else {
                    break;
                }
            },
            .RIGHT => {
                if (guard.pos.x + 1 == map.cols()) return error.IndexOutOfRange;
                if (try map.get(.{ .x = guard.pos.x + 1, .y = guard.pos.y }) == '#') {
                    guard.dir = .DOWN;
                } else {
                    break;
                }
            },
        }
    }
    try map.set(guard.pos, '*');
    switch (guard.dir) {
        .DOWN => {
            try map.set(.{ .x = guard.pos.x, .y = guard.pos.y + 1 }, 'v');
        },
        .UP => {
            try map.set(.{ .x = guard.pos.x, .y = guard.pos.y - 1 }, '^');
        },
        .LEFT => {
            try map.set(.{ .x = guard.pos.x - 1, .y = guard.pos.y }, '<');
        },
        .RIGHT => {
            try map.set(.{ .x = guard.pos.x + 1, .y = guard.pos.y }, '>');
        },
    }
    return map;
}
