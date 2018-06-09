
void init_jelbrek(mach_port_t tfp0, uint64_t kernel_base);
kern_return_t trust_bin(const char *path);
BOOL unsandbox(pid_t pid);
void empower(pid_t pid);
BOOL get_root(pid_t pid);
uint64_t kread_uint64(uint64_t where);
uint32_t kread_uint32(uint64_t where);
size_t kwrite_uint32(uint64_t where, uint32_t value);
size_t kwrite_uint64(uint64_t where, uint64_t value);
//size_t kwrite(uint64_t where, const void *p, size_t size);
//size_t kread(uint64_t where, void *p, size_t size);
kern_return_t remount(uint64_t kernel_base, uint64_t kaslr_slide);
