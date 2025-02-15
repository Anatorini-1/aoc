const std = @import("std");

const Position = struct {
    x: i32,
    y: i32,
    fn distance(self: *Position, other: *Position) Position {
        const dx = self.x - other.x;
        const dy = self.y - other.y;
        return .{ .x = dx, .y = dy };
    }
    fn mul_and_add(self: *Position, other: *Position, scale: i32, x_max: usize, y_max: usize) ?Position {
        const scaled_x = other.x * scale;
        const scaled_y = other.y * scale;
        if (self.x + scaled_x >= x_max) return null;
        if (self.y + scaled_y >= y_max) return null;
        if (self.x + scaled_x < 0) return null;
        if (self.y + scaled_y < 0) return null;
        return Position{ .x = self.x + scaled_x, .y = self.y + scaled_y };
    }
    fn add(self: *Position, other: *Position, x_max: usize, y_max: usize) ?Position {
        if (self.x + other.x >= x_max) return null;
        if (self.y + other.y >= y_max) return null;
        if (self.x + other.x < 0) return null;
        if (self.y + other.y < 0) return null;
        return Position{ .x = self.x + other.x, .y = self.y + other.y };
    }
};

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

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const alloc = gpa.allocator();
    defer _ = gpa.deinit();

    var line_buffer = std.ArrayList(u8).init(alloc);
    defer line_buffer.deinit();
    const reader = file.reader();
    const writer = line_buffer.writer();

    var map = std.ArrayList([]u8).init(alloc);
    defer map.deinit();

    var antenas = std.AutoHashMap(u8, std.ArrayList(Position)).init(alloc);
    defer antenas.deinit();

    while (true) {
        reader.streamUntilDelimiter(writer, '\n', 100) catch |err| switch (err) {
            error.EndOfStream => break,
            error.StreamTooLong => {
                std.debug.print("Line to long", .{});
                return;
            },
            else => unreachable,
        };
        const y = map.items.len;
        for (line_buffer.items, 0..) |val, x| {
            if (val == '.') {
                continue;
            } else {
                const entries = try antenas.getOrPutValue(val, std.ArrayList(Position).init(alloc));
                try entries.value_ptr.append(.{ .x = @intCast(x), .y = @intCast(y) });
            }
        }
        const new_line = try alloc.alloc(u8, line_buffer.items.len);
        std.mem.copyForwards(u8, new_line, line_buffer.items);
        try map.append(new_line);
        line_buffer.clearRetainingCapacity();
    }

    std.debug.print("Part1: {}\n", .{try part1(map, antenas)});
    std.debug.print("Part2: {}\n", .{try part2(map, antenas)});
    for (0..map.items.len) |index| {
        alloc.free(map.items[index]);
    }

    var iter = antenas.keyIterator();
    while (iter.next()) |k| {
        if (antenas.get(k.*)) |arr| {
            arr.deinit();
        }
    }
}

fn part2(map: std.ArrayList([]u8), antenas: std.AutoHashMap(u8, std.ArrayList(Position))) !u32 {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const alloc = gpa.allocator();
    var rval: u32 = 0;
    var rval_map: [][]u8 = undefined;
    rval_map = try alloc.alloc([]u8, map.items.len);
    defer alloc.free(rval_map);
    for (0..rval_map.len) |row| {
        rval_map[row] = try alloc.alloc(u8, map.items[0].len);
        for (0..rval_map[row].len) |i| {
            rval_map[row][i] = '.';
        }
    }
    const width = map.items[0].len;
    const height = map.items.len;
    var iter = antenas.keyIterator();
    while (iter.next()) |k| {
        if (antenas.get(k.*)) |arr| {
            for (0..arr.items.len) |i| {
                for (i + 1..arr.items.len) |j| {
                    var a = arr.items[i];
                    var b = arr.items[j];
                    var a_b = a.distance(&b);
                    var b_a = b.distance(&a);

                    var factor_a: i32 = 0;
                    var factor_b: i32 = 0;

                    while (true) {
                        if (a.mul_and_add(&a_b, factor_a, width, height)) |antinode| {
                            rval_map[@intCast(antinode.y)][@intCast(antinode.x)] = '#';
                            factor_a += 1;
                        } else {
                            break;
                        }
                    }
                    while (true) {
                        if (b.mul_and_add(&b_a, factor_b, width, height)) |antinode| {
                            rval_map[@intCast(antinode.y)][@intCast(antinode.x)] = '#';
                            factor_b += 1;
                        } else {
                            break;
                        }
                    }
                }
            }
        }
    }

    for (0..rval_map.len) |row| {
        for (rval_map[row]) |cell| {
            if (cell == '#') {
                rval += 1;
            }
        }
        alloc.free(rval_map[row]);
    }
    return rval;
}
fn part1(map: std.ArrayList([]u8), antenas: std.AutoHashMap(u8, std.ArrayList(Position))) !u32 {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const alloc = gpa.allocator();
    var rval: u32 = 0;
    var rval_map: [][]u8 = undefined;
    rval_map = try alloc.alloc([]u8, map.items.len);
    defer alloc.free(rval_map);
    for (0..rval_map.len) |row| {
        rval_map[row] = try alloc.alloc(u8, map.items[0].len);
        for (0..rval_map[row].len) |i| {
            rval_map[row][i] = '.';
        }
    }
    const width = map.items[0].len;
    const height = map.items.len;
    var iter = antenas.keyIterator();
    while (iter.next()) |k| {
        if (antenas.get(k.*)) |arr| {
            for (0..arr.items.len) |i| {
                for (i + 1..arr.items.len) |j| {
                    var a = arr.items[i];
                    var b = arr.items[j];
                    var a_b = a.distance(&b);
                    var b_a = b.distance(&a);

                    if (a.add(&a_b, width, height)) |antinode| {
                        rval_map[@intCast(antinode.y)][@intCast(antinode.x)] = '#';
                    }
                    if (b.add(&b_a, width, height)) |antinode| {
                        rval_map[@intCast(antinode.y)][@intCast(antinode.x)] = '#';
                    }
                }
            }
        }
    }

    for (0..rval_map.len) |row| {
        for (rval_map[row]) |cell| {
            if (cell == '#') {
                rval += 1;
            }
        }
        alloc.free(rval_map[row]);
    }
    return rval;
}
