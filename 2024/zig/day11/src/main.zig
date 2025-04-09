const std = @import("std");
const ArrayList = std.ArrayList;

const TS = struct {
    buff: []Node,
    fn init(alloc: std.mem.Allocator) !TS {
        return TS{
            .buff = try alloc.alloc(Node, 100),
        };
    }
};
test "Dupa" {
    var arena = std.heap.ArenaAllocator.init(std.testing.allocator);
    const ts = try TS.init(arena.allocator());
    _ = ts;
    arena.deinit();
}

const Node = struct {
    prev: ?*Node,
    next: ?*Node,
    val: u64,
    pub fn print(self: Node) void {
        var _self = self;
        var current: ?*Node = &_self;
        while (current) |n| {
            std.debug.print("{d}", .{n.val});
            if (n.next) |_| {
                std.debug.print(" -> ", .{});
            }
            current = n.next;
        }
        std.debug.print("\n", .{});
    }
    pub fn len(self: *Node) u32 {
        var length: u32 = 0;
        var current: ?*Node = self;
        while (current) |c| {
            length += 1;
            current = c.next;
        }
        return length;
    }
};

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

    try reader.streamUntilDelimiter(
        writer,
        '\n',
        null,
    );
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    var iter = std.mem.splitSequence(u8, line_buffer.items, " ");
    var numbuff: u64 = try (std.fmt.parseInt(u32, iter.next() orelse unreachable, 10));
    var head = try arena.allocator().create(Node);
    head.next = null;
    head.prev = null;
    head.val = numbuff;

    var current: ?*Node = head;

    while (iter.next()) |number| {
        numbuff = try std.fmt.parseInt(u64, number, 10);
        if (current) |c| {
            c.next = try arena.allocator().create(Node);
            if (c.next) |next| {
                next.prev = c;
                next.next = null;
                next.val = numbuff;
                current = next;
            }
        }
    }
    line_buffer.clearRetainingCapacity();
    var batch: BatchAlloc = try BatchAlloc.init(arena.allocator());

    for (0..25) |_| {
        try look(head, &batch, &line_buffer);
    }
    std.debug.print("{d}\n", .{head.len()});
    arena.deinit();
}

const buffer_size = 100;
const BatchAlloc = struct {
    alloc: std.mem.Allocator,
    buffer: []Node,
    pos: usize,
    pub fn get(self: *BatchAlloc) !*Node {
        if (self.pos == buffer_size) {
            self.buffer = try self.alloc.alloc(Node, buffer_size);
            self.pos = 1;
            return &self.buffer[0];
        } else {
            self.pos += 1;
            return &self.buffer[self.pos - 1];
        }
    }
    pub fn init(alloc: std.mem.Allocator) !BatchAlloc {
        return BatchAlloc{
            .alloc = alloc,
            .buffer = try alloc.alloc(Node, 100),
            .pos = 0,
        };
    }
};

fn look(head: *Node, alloc: *BatchAlloc, buff: *std.ArrayList(u8)) !void {
    var current: ?*Node = head;
    var new_node: *Node = undefined;
    var num: u64 = undefined;

    var buff_len: usize = undefined;

    while (current) |c| {
        buff.clearRetainingCapacity();
        try std.fmt.format(buff.writer(), "{d}", .{c.val});
        buff_len = buff.items.len;

        if (c.val == 0) {
            c.val = 1;
            current = c.next;
        } else if (buff_len % 2 == 0) {
            num = try std.fmt.parseInt(
                u64,
                buff.items[0..(buff_len / 2)],
                10,
            );
            c.val = num;
            num = try std.fmt.parseInt(
                u64,
                buff.items[(buff_len / 2)..buff_len],
                10,
            );
            new_node = try alloc.get();
            new_node.val = num;
            new_node.next = c.next;
            c.next = new_node;
            current = new_node.next;
        } else {
            c.val = c.val * 2024;
            current = c.next;
        }
    }
}
