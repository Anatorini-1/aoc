const std = @import("std");
const buffer_len = 100;

pub fn main() !void {
    var args = std.process.args();
    _ = args.next();
    const filename = args.next() orelse {
        std.debug.print("Filename missing", .{});
        return;
    };
    const file = std.fs.cwd().openFile(filename, .{}) catch {
        std.debug.print("Failed to open file {s}", .{filename});
        return;
    };
    var buffer = try std.BoundedArray(u8, buffer_len).init(0);
    var int_buffer = try std.BoundedArray(i32, buffer_len).init(0);
    const reader = file.reader();
    const writer = buffer.writer();
    var res: u32 = 0;
    var res2: u32 = 0;
    while (true) {
        buffer.clear();
        int_buffer.clear();
        reader.streamUntilDelimiter(writer, '\n', buffer_len) catch |e| switch (e) {
            error.StreamTooLong => {
                std.debug.print("Line to long for buffer size ", .{});
                return;
            },
            error.EndOfStream => break,
            else => unreachable,
        };
        if (buffer.len == 0) break;
        var iter = std.mem.splitSequence(u8, buffer.slice(), " ");
        while (iter.next()) |num| {
            try int_buffer.append(try std.fmt.parseInt(i32, num, 10));
        }
        res += if (isSafe1(int_buffer.slice())) 1 else 0;
        res2 += if (isSafe2(int_buffer.slice())) 1 else 0;
    }
    std.debug.print("Part 1:{}\n", .{res});
    std.debug.print("Part 2:{}\n", .{res2});
}

fn isSafe1(report: []i32) bool {
    if (report.len < 2) return true;
    const increasing: bool = report[1] - report[0] > 0;
    var diff: i32 = undefined;
    for (1..report.len) |i| {
        if (increasing) {
            diff = report[i] - report[i - 1];
        } else {
            diff = report[i - 1] - report[i];
        }
        if (diff < 1 or diff > 3) return false;
    }
    return true;
}

fn isSafe2(report: []i32) bool {
    if (isSafe1(report)) return true;
    var arr = std.BoundedArray(i32, buffer_len).init(0) catch {
        unreachable;
    };
    for (0..report.len) |skip| {
        arr.clear();
        for (0..report.len) |i| {
            if (i == skip) continue;
            arr.append(report[i]) catch {
                unreachable;
            };
        }
        if (isSafe1(arr.slice())) return true;
    }
    return false;
}
