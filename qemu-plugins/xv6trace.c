#include <qemu-plugin.h>

#include <inttypes.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>

/*
 * QEMU requires every plugin to export the API version it was
 * compiled against.
 */
QEMU_PLUGIN_EXPORT int qemu_plugin_version = QEMU_PLUGIN_VERSION;

static FILE *trace_file = NULL;
static bool watch_enabled = false;
static uint64_t watch_addr;
static uint64_t watch_size;
static bool user_range_enabled = false;
static uint64_t user_start;
static uint64_t user_end;

extern bool interesting_user_pc(uint64_t pc);

//  Returns true if the PC is the entry to a kernal funciton
static bool interesting_pc(uint64_t pc)
{
    switch (pc) {
        // kernal functions
        // case 0x80000000: //  _entry
        // case 0x80000bc4: //  acquire
        // case 0x80003f98: //  acquiresleep
        // case 0x800019bc: //  allocpid
        // case 0x80002848: //  argaddr
        // case 0x8000282c: //  argint
        // case 0x80002864: //  argstr
        // case 0x80003c8a: //  begin_op
        // case 0x80002af0: //  binit
        // case 0x80002d06: //  bpin
        // case 0x80002b76: //  bread
        // case 0x80002c7e: //  brelse
        // case 0x80002d3a: //  bunpin
        // case 0x80002c4c: //  bwrite
        // case 0x800024e0: //  clockintr
        // case 0x80000468: //  consoleinit
        // case 0x800002ba: //  consoleintr
        // case 0x80000170: //  consoleread
        // case 0x800000d2: //  consolewrite
        // case 0x80000288: //  consputc
        // case 0x8000160a: //  copyin
        // case 0x800016a0: //  copyinstr
        // case 0x8000151e: //  copyout
        // case 0x800018bc: //  cpuid
        // case 0x80002534: //  devintr
        // case 0x80003a1c: //  dirlink
        // case 0x80003840: //  dirlookup
        // case 0x800022d6: //  either_copyin
        // case 0x8000228a: //  either_copyout
        // case 0x80003d10: //  end_op
        // case 0x800027a0: //  fetchaddr
        // case 0x800027ea: //  fetchstr
        // case 0x80004092: //  filealloc
        // case 0x80004136: //  fileclose
        // case 0x800040f0: //  filedup
        // case 0x8000406e: //  fileinit
        // case 0x8000425a: //  fileread
        // case 0x800041f8: //  filestat
        // case 0x80004324: //  filewrite
        // case 0x8000476c: //  flags2perm
        // case 0x80001918: //  forkret
        // case 0x80000a82: //  freerange
        // case 0x80001328: //  freewalk
        // case 0x8000357e: //  fsinit
        // case 0x80001bf2: //  growproc
        // //case 0x80000b64: //  holding
        // case 0x80004024: //  holdingsleep
        // case 0x800030d2: //  ialloc
        // case 0x8000320c: //  idup
        // case 0x8000307a: //  iinit
        // case 0x80003242: //  ilock
        // case 0x80000b4e: //  initlock
        // case 0x80003c0c: //  initlog
        // case 0x80003f62: //  initsleeplock
        // case 0x800033c4: //  iput
        // case 0x800034b4: //  ireclaim
        // case 0x80001482: //  ismapped
        // case 0x80003330: //  itrunc
        // case 0x800032f0: //  iunlock
        // case 0x80003494: //  iunlockput
        // case 0x8000318e: //  iupdate
        // case 0x80000afe: //  kalloc
        // case 0x800026b0: //  kerneltrap
        // case 0x80005580: //  kernelvec
        // case 0x80004786: //  kexec
        // case 0x80002024: //  kexit
        // case 0x80001c54: //  kfork
        // case 0x80000a1c: //  kfree
        // case 0x80002150: //  killed
        // case 0x80000aca: //  kinit
        // case 0x800020c6: //  kkill
        // case 0x80001172: //  kvminit
        // case 0x80000ed6: //  kvminithart
        // case 0x800010ae: //  kvmmake
        // case 0x80001086: //  kvmmap
        // case 0x8000217a: //  kwait
        // case 0x80003e30: //  log_write
        // case 0x80000e22: //  main
        // case 0x80000fd6: //  mappages
        // case 0x80000caa: //  memcmp
        // case 0x80000d40: //  memcpy
        // case 0x80000ce4: //  memmove
        // case 0x80000c88: //  memset
        // //case 0x800018cc: //  mycpu
        // case 0x800018e8: //  myproc
        // case 0x8000382a: //  namecmp
        // case 0x80003ab6: //  namei
        // case 0x80003ad0: //  nameiparent
        // case 0x80000824: //  panic
        // case 0x80004456: //  pipealloc
        // case 0x8000451e: //  pipeclose
        // case 0x8000467a: //  piperead
        // case 0x80004576: //  pipewrite
        // case 0x8000562c: //  plic_claim
        // case 0x8000564c: //  plic_complete
        // case 0x800055de: //  plicinit
        // case 0x800055f8: //  plicinithart
        // case 0x80000c04: //  pop_off
        // case 0x8000246c: //  prepare_return
        // case 0x8000053e: //  printk
        // case 0x80000860: //  printkinit
        // case 0x80001a7e: //  proc_freepagetable
        // case 0x8000176e: //  proc_mapstacks
        // case 0x800019fa: //  proc_pagetable
        // case 0x80002322: //  procdump
        // case 0x80001806: //  procinit
        // case 0x80000b8e: //  push_off
        // case 0x8000361a: //  readi
        // case 0x80000c50: //  release
        // case 0x80003fec: //  releasesleep
        // case 0x80001fce: //  reparent
        // case 0x80000dc6: //  safestrcpy
        // case 0x80001e16: //  sched
        // case 0x80001d62: //  scheduler
        // case 0x8000212c: //  setkilled
        // case 0x80001f38: //  sleep
        // case 0x80001efc: //  sleep_prepare
        // case 0x80000054: //  start
        // case 0x800035f0: //  stati
        // case 0x80000df8: //  strlen
        // case 0x80000d54: //  strncmp
        // case 0x80000d8a: //  strncpy
        // case 0x800023c6: //  swtch

        // case 0x80002894: //  syscall
        // case 0x8000001c: //  timerinit
        // case 0x80006000: //  trampoline
        // case 0x80002430: //  trapinit
        // case 0x80002454: //  trapinithart
        // case 0x80000884: //  uartinit
        // case 0x800009c0: //  uartintr
        // case 0x80000962: //  uartputc_sync
        // case 0x800008dc: //  uartwrite
        // case 0x80001bb6: //  userinit
        // case 0x8000609c: //  userret
        // case 0x800025a8: //  usertrap
        // case 0x80001282: //  uvmalloc
        // case 0x80001458: //  uvmclear
        // case 0x800013ba: //  uvmcopy
        // case 0x8000118e: //  uvmcreate
        // case 0x8000123e: //  uvmdealloc
        // case 0x80001388: //  uvmfree
        // case 0x800011b4: //  uvmunmap
        // case 0x800056e8: //  virtio_disk_init
        // case 0x80005b10: //  virtio_disk_intr
        // case 0x800058e0: //  virtio_disk_rw
        // case 0x800014a2: //  vmfault
        // case 0x80001f68: //  wakeup
        // case 0x80000efe: //  walk
        // case 0x80000f98: //  walkaddr
        // case 0x80003716: //  writei
        // case 0x80001ed0: //  yield
            return true;

        default:
            return false;
    }
}

static bool range_overlaps(
    uint64_t addr,
    uint64_t size,
    uint64_t watched_addr,
    uint64_t watched_size)
{
    return addr >= watched_addr
        ? addr - watched_addr < watched_size
        : watched_addr - addr < size;
}

static void format_mem_value(
    qemu_plugin_mem_value value,
    char *buffer,
    size_t buffer_size)
{
    switch (value.type) {
    case QEMU_PLUGIN_MEM_VALUE_U8:
        snprintf(buffer, buffer_size, "0x%02" PRIx8, value.data.u8);
        break;
    case QEMU_PLUGIN_MEM_VALUE_U16:
        snprintf(buffer, buffer_size, "0x%04" PRIx16, value.data.u16);
        break;
    case QEMU_PLUGIN_MEM_VALUE_U32:
        snprintf(buffer, buffer_size, "0x%08" PRIx32, value.data.u32);
        break;
    case QEMU_PLUGIN_MEM_VALUE_U64:
        snprintf(buffer, buffer_size, "0x%016" PRIx64, value.data.u64);
        break;
    case QEMU_PLUGIN_MEM_VALUE_U128:
        snprintf(
            buffer,
            buffer_size,
            "0x%016" PRIx64 "%016" PRIx64,
            value.data.u128.high,
            value.data.u128.low
        );
        break;
    default:
        snprintf(buffer, buffer_size, "unknown");
        break;
    }
}

static void mem_access(
    unsigned int vcpu_index,
    qemu_plugin_meminfo_t info,
    uint64_t vaddr,
    void *userdata)
{
    uint64_t pc = (uint64_t)(uintptr_t)userdata;
    uint64_t size = 1ULL << qemu_plugin_mem_size_shift(info);
    qemu_plugin_mem_value value;
    char value_hex[35];

    if (!range_overlaps(vaddr, size, watch_addr, watch_size)) {
        return;
    }

    value = qemu_plugin_mem_get_value(info);
    format_mem_value(value, value_hex, sizeof(value_hex));

    fprintf(
        trace_file,
        "mem,%u,0x%016" PRIx64 ",0x%016" PRIx64 ",%" PRIu64 ",%s,%s\n",
        vcpu_index,
        pc,
        vaddr,
        size,
        qemu_plugin_mem_is_store(info) ? "write" : "read",
        value_hex
    );
}

/*
 * Called every time an instrumented translation block executes.
 *
 * userdata contains the guest PC at which the translation block starts.
 */
static void tb_exec(unsigned int vcpu_index, void *userdata)
{
    uint64_t pc = (uint64_t)(uintptr_t)userdata;

    fprintf(
        trace_file,
        "kernel,%u,0x%016" PRIx64 ",,,,\n",
        vcpu_index,
        pc
    );
}

static void user_pc_exec(unsigned int vcpu_index, void *userdata)
{
    uint64_t pc = (uint64_t)(uintptr_t)userdata;

    fprintf(
        trace_file,
        "user,%u,0x%016" PRIx64 ",,,,\n",
        vcpu_index,
        pc
    );
}

/*
 * Called whenever QEMU translates a new translation block.
 *
 * We extract the information we need here because the TB handle is only
 * valid for the duration of this callback.
 */
static void tb_trans(qemu_plugin_id_t id, struct qemu_plugin_tb *tb)
{
    (void)id;

    uint64_t pc = qemu_plugin_tb_vaddr(tb);

    if (interesting_pc(pc)) {
        qemu_plugin_register_vcpu_tb_exec_cb(
            tb,
            tb_exec,
            QEMU_PLUGIN_CB_NO_REGS,
            (void *)(uintptr_t)pc
        );
    }

    size_t n_insns = qemu_plugin_tb_n_insns(tb);

    for (size_t i = 0; i < n_insns; i++) {
        struct qemu_plugin_insn *insn =
            qemu_plugin_tb_get_insn(tb, i);
        uint64_t insn_pc = qemu_plugin_insn_vaddr(insn);

        if (interesting_user_pc(insn_pc)) {
            qemu_plugin_register_vcpu_insn_exec_cb(
                insn,
                user_pc_exec,
                QEMU_PLUGIN_CB_NO_REGS,
                (void *)(uintptr_t)insn_pc
            );
        }

        if (!watch_enabled ||
            (user_range_enabled &&
             (insn_pc < user_start || insn_pc >= user_end))) {
            continue;
        }

        qemu_plugin_register_vcpu_mem_cb(
            insn,
            mem_access,
            QEMU_PLUGIN_CB_NO_REGS,
            QEMU_PLUGIN_MEM_RW,
            (void *)(uintptr_t)insn_pc
        );
    }
}

/*
 * Called when QEMU shuts down.
 */
static void plugin_exit(qemu_plugin_id_t id, void *userdata)
{
    (void)id;
    (void)userdata;

    if (trace_file != NULL) {
        fflush(trace_file);
        fclose(trace_file);
        trace_file = NULL;
    }
}

/*
 * Plugin entry point.
 *
 * Example:
 *
 *   -plugin ./libxv6trace.so,outfile=my-trace.csv,watch=0x1230,bytes=4
 *
 * The watch option enables instruction-level memory tracing. The optional
 * user-start and user-end options restrict those callbacks to a PC range.
 *
 * NOTE: QEMU reserves the option name "file" for the plugin path itself,
 * so plugin-specific arguments must use a different name.
 */
QEMU_PLUGIN_EXPORT int qemu_plugin_install(
    qemu_plugin_id_t id,
    const qemu_info_t *info,
    int argc,
    char **argv)
{
    const char *trace_path = "qemu-trace.csv";

    if (!info->system_emulation) {
       fprintf(stderr, "xv6trace requires QEMU system emulation\n");
       return -1;
    }

    for (int i = 0; i < argc; i++) {
       if (strncmp(argv[i], "outfile=", 8) == 0) {
           trace_path = argv[i] + 8;
       } else if (strncmp(argv[i], "watch=", 6) == 0) {
           char *end;
           errno = 0;
           watch_addr = strtoull(argv[i] + 6, &end, 0);
           if (errno != 0 || *end != '\0') {
               fprintf(stderr, "xv6trace: invalid watch address: %s\n",
                       argv[i] + 6);
               return -1;
           }
           watch_enabled = true;
       } else if (strncmp(argv[i], "bytes=", 6) == 0) {
           char *end;
           errno = 0;
           watch_size = strtoull(argv[i] + 6, &end, 0);
           if (errno != 0 || *end != '\0' || watch_size == 0) {
               fprintf(stderr, "xv6trace: invalid watch size: %s\n",
                       argv[i] + 6);
               return -1;
           }
       } else if (strncmp(argv[i], "user-start=", 11) == 0) {
           char *end;
           errno = 0;
           user_start = strtoull(argv[i] + 11, &end, 0);
           if (errno != 0 || *end != '\0') {
               fprintf(stderr, "xv6trace: invalid user start: %s\n",
                       argv[i] + 11);
               return -1;
           }
           user_range_enabled = true;
       } else if (strncmp(argv[i], "user-end=", 9) == 0) {
           char *end;
           errno = 0;
           user_end = strtoull(argv[i] + 9, &end, 0);
           if (errno != 0 || *end != '\0') {
               fprintf(stderr, "xv6trace: invalid user end: %s\n",
                       argv[i] + 9);
               return -1;
           }
           user_range_enabled = true;
       } else {
           fprintf(stderr, "xv6trace: unknown option: %s\n", argv[i]);
           return -1;
       }
    }

    if (watch_enabled && watch_size == 0) {
        watch_size = 1;
    }

    if (user_range_enabled && user_start >= user_end) {
        fprintf(stderr, "xv6trace: user-start must be below user-end\n");
        return -1;
    }

    if (!watch_enabled && (watch_size != 0 || user_range_enabled)) {
        fprintf(stderr,
                "xv6trace: watch= is required with bytes= or user PC ranges\n");
        return -1;
    }

    trace_file = fopen(trace_path, "w");

    if (trace_file == NULL) {
        perror("xv6trace: fopen");
        return -1;
    }

    /*
     * Use a large stdio buffer so that we are not doing a disk write
     * for every single translation block.
     */
    setvbuf(
        trace_file,
        NULL,
        _IOFBF,
        1024 * 1024
    );

    fprintf(trace_file, "record,vcpu,pc,address,size,operation,value\n");

    /*
     * Ask QEMU to notify us whenever it translates a block.
     */
    qemu_plugin_register_vcpu_tb_trans_cb(id, tb_trans);

    /*
     * Cleanly close the trace when QEMU exits.
     */
    qemu_plugin_register_atexit_cb(
        id,
        plugin_exit,
        NULL
    );

    return 0;
}