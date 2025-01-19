const std = @import("std");
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

    var line = std.ArrayList(u8).init(alloc);
    const writer = line.writer();
    const reader = file.reader();
    var res: i32 = 0;
    var res2: i32 = 0;
    while (true) {
        reader.streamUntilDelimiter(writer, '\n', null) catch |e| switch (e) {
            error.EndOfStream => break,
            error.StreamTooLong => {
                std.debug.print("Line to long", .{});
                return;
            },
            else => unreachable,
        };
        res += try part1(line.items);
        res2 += try part2(line.items);
        line.clearRetainingCapacity();
    }
    std.debug.print("Part 1:{}\n", .{res});
    std.debug.print("Part 2:{}\n", .{res2});
}

fn part2(line: []u8) !i32 {
    const state = enum { prefix, arg1, arg2, disabled };
    const prefix = "mul(";
    const do = "do()";
    const dont = "don't()";
    var i: usize = 0;
    var c: u8 = undefined;
    const current_state = struct {
        var val: state = state.prefix;
    };
    var arg_start: usize = undefined;
    var instruction = struct { a: i32, b: i32 }{ .a = undefined, .b = undefined };
    var rval: i32 = 0;
    while (true and i < line.len) {
        c = line[i];
        switch (current_state.val) {
            state.prefix => {
                if (i + 4 >= line.len) break;
                if (std.mem.eql(u8, line[i .. i + 4], prefix)) {
                    current_state.val = state.arg1;
                    i += 4;
                    arg_start = i;
                } else if (i + 7 < line.len and std.mem.eql(u8, line[i .. i + 7], dont)) {
                    current_state.val = .disabled;
                } else {
                    i += 1;
                }
            },
            state.arg1 => {
                if (c >= '0' and c <= '9') {
                    i += 1;
                } else if (c == ',') {
                    instruction.a = try std.fmt.parseInt(i32, line[arg_start..i], 10);
                    i += 1;
                    current_state.val = state.arg2;
                    arg_start = i;
                } else {
                    current_state.val = state.prefix;
                }
            },
            state.arg2 => {
                if (c >= '0' and c <= '9') {
                    i += 1;
                } else if (c == ')') {
                    instruction.b = try std.fmt.parseInt(i32, line[arg_start..i], 10);
                    rval += instruction.a * instruction.b;
                    current_state.val = state.prefix;
                    i += 1;
                } else {
                    current_state.val = .prefix;
                }
            },
            .disabled => {
                if (i + 4 >= line.len) break;
                if (std.mem.eql(u8, line[i .. i + 4], do)) {
                    current_state.val = state.prefix;
                }
                i += 1;
            },
        }
    }
    return rval;
}

fn part1(line: []u8) !i32 {
    const state = enum { prefix, arg1, arg2 };
    const prefix = "mul(";
    var i: usize = 0;
    var c: u8 = undefined;
    var current_state = state.prefix;
    var arg_start: usize = undefined;
    var instruction = struct { a: i32, b: i32 }{ .a = undefined, .b = undefined };
    var rval: i32 = 0;
    while (true and i < line.len) {
        c = line[i];
        switch (current_state) {
            state.prefix => {
                if (i + 4 >= line.len) break;
                if (std.mem.eql(u8, line[i .. i + 4], prefix)) {
                    current_state = state.arg1;
                    i += 4;
                    arg_start = i;
                } else {
                    i += 1;
                }
            },
            state.arg1 => {
                if (c >= '0' and c <= '9') {
                    i += 1;
                } else if (c == ',') {
                    instruction.a = try std.fmt.parseInt(i32, line[arg_start..i], 10);
                    i += 1;
                    current_state = state.arg2;
                    arg_start = i;
                } else {
                    current_state = state.prefix;
                }
            },
            state.arg2 => {
                if (c >= '0' and c <= '9') {
                    i += 1;
                } else if (c == ')') {
                    instruction.b = try std.fmt.parseInt(i32, line[arg_start..i], 10);
                    rval += instruction.a * instruction.b;
                    current_state = state.prefix;
                    i += 1;
                } else {
                    current_state = .prefix;
                }
            },
        }
    }
    return rval;
}
