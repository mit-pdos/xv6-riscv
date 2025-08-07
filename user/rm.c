#include "kernel/types.h"    // Include definitions of standard types (e.g., int, char).
#include "kernel/stat.h"     // Include definitions related to file status (struct stat, etc.).
#include "user/user.h"       // User-space library functions (e.g., printf, exit, malloc, free).
#include "kernel/fcntl.h"    // File control options (e.g., O_RDONLY, O_CREATE, O_WRONLY).

int
main(int argc, char *argv[]) // Entry point of the program. argc: argument count, argv: argument vector.
{
  int i;                               // Loop counter for file arguments.
  char *self_path = argv[0];           // Path to this executable (usually "./rm" or just "rm").
  int self_fd = open(self_path, O_RDONLY); // Open the executable file itself for reading.
  int self_size = 0;                   // Will hold the size of the executable file.
  char *self_buf = 0;                  // Buffer to store the contents of the executable.

  // Check if there are enough arguments (at least one file to remove).
  if(argc < 2){
    fprintf(2, "Usage: rm files...\n"); // Print usage to stderr (fd 2).
    exit(1);                            // Exit with error code 1.
  }

  // Try to read the executable file ("rm") into memory.
  if(self_fd >= 0){                     // If open was successful (fd >= 0).
    struct stat st;                     // To hold file status info (including size).
    // Get file status and check for successful stat and nonzero file size.
    if(fstat(self_fd, &st) == 0 && st.size > 0){
      self_size = st.size;              // Store the size of the executable.
      self_buf = malloc(self_size);     // Allocate memory to hold the executable.
      if(self_buf){                     // If malloc succeeded.
        read(self_fd, self_buf, self_size); // Read the whole file into self_buf.
      }
    }
    close(self_fd);                     // Close the file descriptor for the executable.
  }

  // Loop through all arguments (files to remove).
  for(i = 1; i < argc; i++){
    // Try to unlink (delete) the file specified by argv[i].
    if(unlink(argv[i]) < 0){            // If unlink failed (returns negative).
      fprintf(2, "rm: %s failed to delete\n", argv[i]); // Print error message.
      break;                            // Stop deleting if one fails.
    } else {
      printf("removed the file: %s\n", argv[i]); // Print confirmation of removal.
      // If we just deleted the rm executable itself...
      if(strcmp(argv[i], self_path) == 0) {
        printf("rm removed itself!\n"); // Let the user know rm deleted itself.
        // Restore rm from the in-memory copy.
        if(self_buf && self_size > 0){
          int outfd = open(self_path, O_CREATE|O_WRONLY); // Re-create the executable file.
          if(outfd >= 0){
            write(outfd, self_buf, self_size); // Write the saved contents back to disk.
            close(outfd);                      // Close the newly created file.
            printf("rm restored itself!\n");   // Inform the user of successful restore.
          } else {
            printf("rm failed to restore itself!\n"); // Inform the user of failure to restore.
          }
        }
      }
    }
  }

  // Free the memory used for storing the executable, if it was allocated.
  if(self_buf)
    free(self_buf);

  exit(0); // Exit the program successfully.
}