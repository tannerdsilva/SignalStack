# SignalStack

## Developer-friendly, cross-platform signal handler library

SignalStack serves a simple purpose: attach one or many handlers to a process signal event.

As a developer with interests in integrating signal handlers into your code, you are posed with a challenge:

With the base system functions, only one handler can be attached to a given signal.

This means that you (as a developer) have no guarantee that your registered signal handlers wont override or conflict with other signal handlers in your code.

SignalStack allows handler functions to be stacked onto a single global instance. This allows for perfect cross-library functionality when multiple libraries require access to the same signal handler.