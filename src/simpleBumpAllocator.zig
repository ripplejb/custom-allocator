const SimpleBumpAllocator = struct {
    ptr: *anyopaque,
    vtable: *const VTable,

    pub const VTable = struct {
        alloc: *const fn (
            ctx: *anyopaque,
            len: usize,
            ptr_align: u8,
            ret_addr: usize,
        ) ?[*]u8,

        resize: *const fn (
            ctx: *anyopaque,
            buf: []u8,
            ptr_align: u8,
            new_len: usize,
            ret_add: usize,
        ) bool,

        free: *const fn (
            ctx: *anyopaque,
            buf: []u8,
            ptr_align: u8,
            ret_addr: usize,
        ) void,
    };
};
