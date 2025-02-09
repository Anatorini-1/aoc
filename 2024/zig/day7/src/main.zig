const std = @import("std");
const readState = enum { rules, pages };

pub fn main() !void {
    var args = std.process.args();
    _ = args.skip();
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const alloc = gpa.allocator();
    defer _ = gpa.deinit();
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

    var operands = std.ArrayList(u32).init(alloc);
    defer operands.deinit();

    var result: u64 = undefined;
    var part1_res: u64 = 0;
    var part2_res: u64 = 0;
    var c: u32 = 0;
    while (true) {
        std.debug.print("{}\n", .{c});
        c += 1;
        reader.streamUntilDelimiter(writer, '\n', 100) catch |err| switch (err) {
            error.EndOfStream => break,
            error.StreamTooLong => {
                std.debug.print("Line to long", .{});
                return;
            },
            else => {
                std.debug.print("Oh noooo", .{});
            },
        };
        var iter = std.mem.splitSequence(u8, line_buffer.slice(), ":");
        if (iter.next()) |result_str| {
            result = try std.fmt.parseInt(u64, result_str, 10);
        }
        if (iter.next()) |numbers| {
            var num_iter = std.mem.splitSequence(u8, numbers, " ");
            _ = num_iter.next();
            while (num_iter.next()) |num| {
                try operands.append(try std.fmt.parseInt(u32, num, 10));
            }
        }
        part1_res += try part1(result, operands.items);
        part2_res += try part2(result, operands.items);

        line_buffer.clear();
        operands.clearRetainingCapacity();
    }
    std.debug.print("Part 1 {}\n", .{part1_res});
    std.debug.print("Part 2 {}\n", .{part2_res});
}

fn part1(result: u64, operands: []u32) !u64 {
    const permutations: u32 = @as(u32, 1) << @intCast((operands.len - 1));
    const shift_base: u32 = 1;
    var current: u64 = undefined;
    var alloc = std.heap.GeneralPurposeAllocator(.{}){};
    var buffer = std.ArrayList(u8).init(alloc.allocator());
    defer buffer.deinit();
    for (0..permutations) |permutation| {
        current = operands[0];
        for (0..operands.len - 1) |operator| {
            const mask: u32 = shift_base << @intCast(operator);
            const arg = (permutation & mask) >> @intCast(operator);
            switch (arg) {
                0b0 => {
                    current += operands[operator + 1];
                },
                0b1 => {
                    current *= operands[operator + 1];
                },
                else => {
                    unreachable;
                },
            }
        }
        if (current == result) {
            return result;
        }
    }
    return 0;
}

fn part2(result: u64, operands: []u32) !u64 {
    const permutations: u32 = @as(u32, 1) << @intCast((operands.len - 1) * 2);
    const shift_base: u32 = 3;
    var current: u64 = undefined;
    var alloc = std.heap.GeneralPurposeAllocator(.{}){};
    var buffer = std.ArrayList(u8).init(alloc.allocator());
    var tmp: u32 = undefined;
    defer buffer.deinit();
    perms: for (0..permutations) |permutation| {
        current = operands[0];
        for (0..operands.len - 1) |operator| {
            const mask: u32 = shift_base << @intCast(operator * 2);
            const arg = (permutation & mask) >> @intCast(operator * 2);
            switch (arg) {
                0b00 => {
                    current += operands[operator + 1];
                },
                0b01 => {
                    current *= operands[operator + 1];
                },
                0b10 => {
                    tmp = operands[operator + 1];
                    while (tmp > 0) {
                        current = current * 10 + tmp % 10;
                        tmp /= 10;
                    }
                },
                else => {
                    continue :perms;
                },
            }
        }
        if (current == result) {
            return result;
        }
    }
    return 0;
}
