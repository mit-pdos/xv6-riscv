// ipctest.c - Clean version with single includes and main function

#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int main() {
    printf("Starting IPC Tests...\n");
    
    // Test shared memory
    printf("\n=== Shared Memory Test ===\n");
    int shm_key = 1234;
    
    // Create shared memory
    int shm_id = shm_create(shm_key);
    if(shm_id < 0) {
        printf("Failed to create shared memory\n");
        return -1;
    }
    printf("Created shared memory with ID: %d\n", shm_id);
    
    // Get shared memory pointer
    int* shm_ptr = (int*)shm_get(shm_key);
    if(shm_ptr == (void*)-1) {
        printf("Failed to get shared memory\n");
        return -1;
    }
    printf("Got shared memory pointer: %p\n", shm_ptr);
    
    // Test writing/reading from shared memory
    *shm_ptr = 42;
    printf("Wrote value 42 to shared memory\n");
    printf("Read value from shared memory: %d\n", *shm_ptr);
    
    // Test mailbox
    printf("\n=== Mailbox Test ===\n");
    int mbox_key = 5678;
    
    // Create mailbox
    int mbox_id = mbox_create(mbox_key);
    if(mbox_id < 0) {
        printf("Failed to create mailbox\n");
        return -1;
    }
    printf("Created mailbox with ID: %d\n", mbox_id);
    
    // Test sending message
    int test_msg = 123;
    if(mbox_send(mbox_id, test_msg) < 0) {
        printf("Failed to send message\n");
        return -1;
    }
    printf("Sent message: %d\n", test_msg);
    
    // Test receiving message
    int recv_msg;
    if(mbox_recv(mbox_id, &recv_msg) < 0) {
        printf("Failed to receive message\n");
        return -1;
    }
    printf("Received message: %d\n", recv_msg);
    
    // Clean up
    if(shm_close(shm_key) < 0) {
        printf("Failed to close shared memory\n");
    } else {
        printf("Closed shared memory\n");
    }
    
    printf("\nIPC Tests completed!\n");
    return 0;
}