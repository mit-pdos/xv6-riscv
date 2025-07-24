
The `run-tests.sh` script is called by various testers to do the work of
testing. Each test is actually fairly simple: it is a comparison of standard
output and standard error, as per the program specification.

In any given program specification directory, there exists a specific `tests/`
directory which holds the expected return code, standard output, and standard
error in files called `n.rc`, `n.out`, and `n.err` (respectively) for each
test `n`. The testing framework just starts at `1` and keeps incrementing
tests until it can't find any more or encounters a failure. Thus, adding new
tests is easy; just add the relevant files to the tests directory at the
lowest available number.

The files needed to describe a test number `n` are:
- `n.rc`: The return code the program should return (usually 0 or 1)
- `n.out`: The standard output expected from the test
- `n.err`: The standard error expected from the test
- `n.run`: How to run the test (which arguments it needs, etc.)
- `n.desc`: A short text description of the test
- `n.pre` (optional): Code to run before the test, to set something up
- `n.post` (optional): Code to run after the test, to clean something up

There is also a single file called `pre` which gets run once at the 
beginning of testing; this is often used to do a more complex build
of a code base, for example. To prevent repeated time-wasting pre-test
activity, suppress this with the `-s` flag (as described below).

In most cases, a wrapper script is used to call `run-tests.sh` to do the
necessary work.

The options for `run-tests.sh` include:
* `-h` (the help message)
* `-v` (verbose: print what each test is doing)
* `-t n` (run only test `n`)
* `-c` (continue even after a test fails)
* `-d` (run tests not from `tests/` directory but from this directory instead)
* `-s` (suppress running the one-time set of commands in `pre` file)

There is also another script used in testing of `xv6` projects, called
`run-xv6-command.exp`. This is an
[`expect`](https://en.wikipedia.org/wiki/Expect) script which launches the
qemu emulator and runs the relevant testing command in the xv6 environment
before automatically terminating the test. It is used by the `run-tests.sh`
script as described above and thus not generally called by users directly.


