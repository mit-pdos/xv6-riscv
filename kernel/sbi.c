#include "types.h"
#include "riscv.h"
#include "defs.h"
#include "sbi.h"

void _entry();

struct sbiret sbi_ecall(int ext, int fid, uint64 arg0, uint64 arg1, 
        uint64 arg2, uint64 arg3, uint64 arg4, uint64 arg5)
{
	struct sbiret ret;

	register uint64 a0 asm ("a0") = arg0;
	register uint64 a1 asm ("a1") = arg1;
	register uint64 a2 asm ("a2") = arg2;
	register uint64 a3 asm ("a3") = arg3;
	register uint64 a4 asm ("a4") = arg4;
	register uint64 a5 asm ("a5") = arg5;
	register uint64 a6 asm ("a6") = fid;
	register uint64 a7 asm ("a7") = ext;
	asm volatile ("ecall"
		      : "+r" (a0), "+r" (a1)
		      : "r" (a2), "r" (a3), "r" (a4), "r" (a5), "r" (a6), "r" (a7)
		      : "memory");

	ret.error = a0;
	ret.value = a1;

	return ret;
}

static inline long sbi_get_spec_version(void)
{
	struct sbiret ret;

	ret = sbi_ecall(SBI_EXT_ID_BASE, SBI_BASE_GET_SPEC_VERSION, 0, 0, 0, 0, 0, 0);
	if (ret.error) {
		panic("sbi_get_spec_version failed");		
	}
	return ret.value;
}

static inline long sbi_probe_extension(int extid)
{
	struct sbiret ret;

	ret = sbi_ecall(SBI_EXT_ID_BASE, SBI_BASE_PROBE_EXTENSION, extid, 0, 0, 0, 0, 0);
	if (ret.error) {
		return ret.error;
	}
    return ret.value;
}

static inline long sbi_hart_start(uint64 hartid, uint64 saddr, uint64 priv)
{
	struct sbiret ret;

	ret = sbi_ecall(SBI_EXT_ID_HSM, SBI_HSM_HART_START, hartid, saddr, priv, 0, 0, 0);
	if (ret.error) {
		return ret.error;
	}
    return ret.value;
}

void sbiinit(void)
{
    uint64 version = sbi_get_spec_version();
	uint64 major = (version >> SBI_SPEC_VERSION_MAJOR_SHIFT) &
	        SBI_SPEC_VERSION_MAJOR_MASK;
	uint64 minor = version & SBI_SPEC_VERSION_MINOR_MASK;
    printf("SBI specification v%d.%d detected\n", major, minor);

	if (sbi_probe_extension(SBI_EXT_ID_TIME) > 0) {
		printf("SBI TIME extension detected\n");
	}

	if (sbi_probe_extension(SBI_EXT_ID_IPI) > 0) {
		printf("SBI IPI extension detected\n");
	}

	if (sbi_probe_extension(SBI_EXT_ID_RFNC) > 0) {
		printf("SBI RFNC extension detected\n");
	}

	if (sbi_probe_extension(SBI_EXT_ID_HSM) > 0) {
		printf("SBI HSM extension detected\n");

		uint64 ret = SBI_SUCCESS;
		uint64 hartid = 1;
		while (ret == SBI_SUCCESS) {
			ret = sbi_hart_start(hartid, (uint64)_entry, 0);
			hartid++;
		}
	}

	if (sbi_probe_extension(SBI_EXT_ID_SRST) > 0) {
		printf("SBI SRST extension detected\n");
	}

	if (sbi_probe_extension(SBI_EXT_ID_PMU) > 0) {
		printf("SBI PMU extension detected\n");
	}

	printf("\n");
}
