const std = @import("std");
const Alignment = std.mem.Alignment;

const SimpleBumpAllocator = struct {
    _buffer: []u8,
    _offset: usize,

    pub fn init(self: *SimpleBumpAllocator) SimpleBumpAllocator {
        self._buffer = std.heap.page_allocator.alloc([]u8, 1024 * 1024);
        self._offset = 0;
    }

    pub fn deinit(self: *SimpleBumpAllocator) SimpleBumpAllocator {
        std.heap.page_allocator.free(self._buffer);
        self._offset = 0;
    }

    pub fn allocator(self: *SimpleBumpAllocator) std.mem.Allocator {
        return .{ .ptr = self, .vtable = &.{ .alloc = allocImpl, .resize = resizeImpl, .remap = remapImpl, .free = freeImpl } };
    }

    pub fn allocImpl(ptr: *anyopaque, len: usize, alignment: Alignment, ret_addr: usize) ?[*]u8 {
        _ = len; // autofix
        _ = alignment; // autofix
        _ = ret_addr; // autofix
        const self: *SimpleBumpAllocator = @ptrCast(@alignCast(ptr));
        _ = self; // autofix
        return null;
    }

    pub fn resizeImpl(ptr: *anyopaque, memory: []u8, alignment: Alignment, new_len: usize, ret_addr: usize) bool {
        _ = ptr; // autofix
        _ = memory; // autofix
        _ = alignment; // autofix
        _ = new_len; // autofix
        _ = ret_addr; // autofix
        return null;
    }

    pub fn remapImpl(ptr: *anyopaque, memory: []u8, alignment: Alignment, new_len: usize, ret_addr: usize) ?[*]u8 {
        _ = ptr; // autofix
        _ = memory; // autofix
        _ = alignment; // autofix
        _ = new_len; // autofix
        _ = ret_addr; // autofix
        return null;
    }

    pub fn freeImpl(ptr: *anyopaque, memory: []u8, alignment: Alignment, ret_addr: usize) void {
        _ = ptr; // autofix
        _ = memory; // autofix
        _ = alignment; // autofix
        _ = ret_addr; // autofix
    }
};
