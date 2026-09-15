#include <qemu-plugin.h>

#include <inttypes.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/*
 * QEMU requires every plugin to export the API version it was
 * compiled against.
 */
QEMU_PLUGIN_EXPORT int qemu_plugin_version = QEMU_PLUGIN_VERSION;

static FILE *trace_file = NULL;

static bool interesting_pc(uint64_t pc)
{
    switch (pc) {
        case 0x80001e16:  // sched
        case 0x80002894:  // syscall
        case 0x80001f38:  // sleep
        case 0x80001f68:  // wakeup
        case 0x80001d62:  // scheduler
        case 0x800025a8:  // usertrap
        case 0x80002932:  // sys_fork
        case 0x80001c54:  // kfork
            return true;

        default:
            return false;
    }
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
        "%u,0x%016" PRIx64 "\n",
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
static void tb_trans(struct qemu_plugin_tb *tb, void *userdata)
{
    (void)userdata;

    uint64_t pc = qemu_plugin_tb_vaddr(tb);

    if (!interesting_pc(pc)) {
        return;
    }

    /*
     * Register a callback that will run whenever this translated block
     * actually executes.
     *
     * We pass the TB start PC as callback userdata.
     */
    qemu_plugin_register_vcpu_tb_exec_cb(
        tb,
        tb_exec,
        QEMU_PLUGIN_CB_NO_REGS,
        (void *)(uintptr_t)pc
    );
}

/*
 * Called when QEMU shuts down.
 */
static void plugin_exit(void *userdata)
{
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
 *   -plugin ./libxv6trace.so,outfile=my-trace.csv
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

    /*
    * Parse:
    *
    *     outfile=some-file.csv
    */
    for (int i = 0; i < argc; i++) {
       if (strncmp(argv[i], "outfile=", 8) == 0) {
           trace_path = argv[i] + 8;
       } else {
           fprintf(stderr, "xv6trace: unknown option: %s\n", argv[i]);
           return -1;
       }
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

    fprintf(trace_file, "vcpu,tb_pc\n");

    /*
     * Ask QEMU to notify us whenever it translates a block.
     */
    qemu_plugin_register_vcpu_tb_trans_cb(
        id,
        tb_trans,
        NULL
    );

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