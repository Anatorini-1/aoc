const std = @import("std");

const position = struct { x: usize, y: usize };
const mapType = std.ArrayList([]u8);

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const alloc = gpa.allocator();
    var args = std.process.args();
    _ = args.skip();
    const filename = args.next() orelse {
        std.debug.print("Pass a file name", .{});
        return error.FileNameMissing;
    };
    const file = std.fs.cwd().openFile(filename, .{}) catch {
        std.debug.print("Failed to open file", .{});
        return error.IOError;
    };
    var line_buffer = std.ArrayList(u8).init(alloc);
    defer line_buffer.deinit();

    const writer = line_buffer.writer();
    var reader = file.reader();

    var map = mapType.init(alloc);
    defer map.deinit();

    var new_row: []u8 = undefined;
    while (true) {
        reader.streamUntilDelimiter(writer, '\n', null) catch {
            break;
        };
        new_row = try alloc.alloc(u8, line_buffer.items.len);
        for (0..line_buffer.items.len) |index| {
            new_row[index] = try std.fmt.parseInt(u8, line_buffer.items[index .. index + 1], 10);
        }
        try map.append(new_row);
        line_buffer.clearRetainingCapacity();
    }

    try solve(map, alloc);
    for (map.items) |row| {
        alloc.free(row);
    }
}

fn solve(map: mapType, alloc: std.mem.Allocator) !void {
    var part1: u32 = 0;
    var part2: u32 = 0;

    const rows = map.items.len;
    const cols = map.items[0].len;
    var new_pos: *position = undefined;

    var trailheads = std.ArrayList(position).init(alloc);
    var peaks = std.ArrayList(position).init(alloc);
    const visited: []bool = try alloc.alloc(bool, rows * cols);

    defer trailheads.deinit();
    defer peaks.deinit();
    defer alloc.free(visited);

    for (map.items, 0..) |row, y| {
        for (row, 0..) |cell, x| {
            if (cell == 0) {
                new_pos = try trailheads.addOne();
                new_pos.y = y;
                new_pos.x = x;
            } else if (cell == 9) {
                new_pos = try peaks.addOne();
                new_pos.y = y;
                new_pos.x = x;
            }
        }
    }

    for (trailheads.items) |head| {
        @memset(visited, false);
        const rating = try explore(map, visited, head);
        var score: u32 = 0;
        for (peaks.items) |peak| {
            const offset = cols * peak.y + peak.x;
            if (visited[offset]) score += 1;
        }
        part1 += score;
        part2 += rating;
    }
    std.debug.print("Part 1: {}\nPart 2: {}\n", .{ part1, part2 });
}

fn explore(map: mapType, visited: []bool, start: position) !u32 {
    const y_max = map.items.len;
    const x_max = map.items[0].len;
    var paths: u32 = 0;
    visited[start.y * x_max + start.x] = true;
    const current = map.items[start.y][start.x];
    const next = current + 1;

    if (current == 9) return 1;

    if (start.x >= 1 and map.items[start.y][start.x - 1] == next) {
        paths += try explore(map, visited, .{ .y = start.y, .x = start.x - 1 });
    }
    if (start.x + 1 < x_max and map.items[start.y][start.x + 1] == next) {
        paths += try explore(map, visited, .{ .y = start.y, .x = start.x + 1 });
    }
    if (start.y >= 1 and map.items[start.y - 1][start.x] == next) {
        paths += try explore(map, visited, .{ .y = start.y - 1, .x = start.x });
    }
    if (start.y + 1 < y_max and map.items[start.y + 1][start.x] == next) {
        paths += try explore(map, visited, .{ .y = start.y + 1, .x = start.x });
    }

    return paths;
}
