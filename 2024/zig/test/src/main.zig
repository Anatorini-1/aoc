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
    var count: u32 = 0;

    while (true) {
        reader.streamUntilDelimiter(writer, '\n', 100) catch |err| switch (err) {
            error.EndOfStream => break,
            error.StreamTooLong => {
                std.debug.print("Line to long", .{});
                return;
            },
            else => unreachable,
        };
        count += 1;

        line_buffer.clear();
    }
    std.debug.print("{}\n", .{count});
}
