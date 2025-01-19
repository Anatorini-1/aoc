const std = @import("std");
const alloc = std.heap.page_allocator;

pub fn main() !void {
    var args = std.process.args();
    _ = args.skip();
    const filename = args.next() orelse {
        std.debug.print("Filename missing", .{});
        return;
    };
    const file = std.fs.cwd().openFile(filename, .{}) catch {
        std.debug.print("Failed to open the file", .{});
        return;
    };
    defer file.close();

    var line_buffer = try std.BoundedArray(u8, 100).init(0);
    const reader = file.reader();
    const writer = line_buffer.writer();

    var line: u32 = 0;
    var data: [2][1000]u32 = undefined;

    while (true) {
        reader.streamUntilDelimiter(writer, '\n', 100) catch {
            break;
        };
        var iter = std.mem.splitSequence(u8, line_buffer.slice(), " ");
        data[0][line] = try std.fmt.parseInt(u32, iter.next() orelse "-1", 10);
        while (iter.next()) |i| {
            if (i.len > 0) {
                data[1][line] = try std.fmt.parseInt(u32, i, 10);
                break;
            }
        }
        line += 1;
        line_buffer.clear();
    }
    std.mem.sort(u32, &data[0], {}, comptime std.sort.asc(u32));
    std.mem.sort(u32, &data[1], {}, comptime std.sort.asc(u32));
    const p1 = part1(data[0][0..line], data[1][0..line]);
    std.debug.print("{}\n", .{p1});
    const p2 = part2(data[0][0..line], data[1][0..line]);
    std.debug.print("{}\n", .{p2});
}

pub fn part1(left: []u32, right: []u32) u32 {
    std.debug.assert(left.len == right.len);
    var res: u32 = 0;
    var a: u32 = undefined;
    var b: u32 = undefined;
    const len = left.len;
    for (0..len) |i| {
        a = left[i];
        b = right[i];
        if (a > b) {
            res += a - b;
        } else {
            res += b - a;
        }
    }
    return res;
}
pub fn part2(left: []u32, right: []u32) u32 {
    var res: u32 = 0;
    var count: u32 = 0;
    for (left) |l| {
        count = 0;
        for (right) |r| {
            if (l == r) {
                count += 1;
            }
        }
        res += l * count;
    }
    return res;
}
