# SignalStack

## Developer-friendly, cross-platform signal handler library

SignalStack serves a simple purpose: attach one or many handlers to a process signal event.

As a developer with interests in integrating signal handlers into your code, you are posed with a challenge:

With the base system functions, only one handler can be attached to a given signal.

This means that you (as a developer) have no guarantee that your registered signal handlers wont override or conflict with other signal handlers in your code.

SignalStack allows handler functions to be stacked onto a static global instance. This allows for perfect cross-library functionality when multiple libraries require access to the same signal handler.

## Example

```
// Add a series of functions to the stack of the SIGINT handler.
//   - Add three handler functions, then remove the middle function from the stack

let handleID1 = await SignalStack.global.add(signal:SIGINT) { caughtSignal in
	print("signal function 1 called")
}
let handleID2 = await SignalStack.global.add(signal:SIGINT) { caughtSignal in
	print("signal function 2 called")
}
let handleID3 = SignalStack.global.add(signal:SIGINT) { caughtSignal in
	print("signal function 3 called")
}

await SignalStack.global.remove(signal:SIGINT, handle:handleID2)

//function 1 and 3 are called when SIGINT is caught
```