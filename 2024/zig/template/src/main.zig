const std = @import("std");
const ArrayList = std.ArrayList;
pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const alloc = gpa.allocator();

    var args = std.process.args();
    _ = args.skip();
    const file = try std.fs.cwd().openFile(
        args.next() orelse unreachable,
        .{},
    );
    var reader = file.reader();
    var line_buffer = ArrayList(u8).init(alloc);
    defer line_buffer.deinit();
    const writer = line_buffer.writer();

    while (true) {
        reader.streamUntilDelimiter(
            writer,
            '\n',
            null,
        ) catch |e| switch (e) {
            error.EndOfStream => break,
            else => unreachable,
        };

        std.debug.print("{s}\n", .{line_buffer.items});
        line_buffer.clearRetainingCapacity();
    }
}
