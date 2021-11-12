#if os(Linux)
import Glibc
#elseif os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
import Darwin
#endif

public actor SignalStack {
	public static let global = SignalStack()
	fileprivate typealias MainSignalHandler = @convention(c)(Int32) -> Void
	fileprivate static let mainHandler:MainSignalHandler = { sigVal in
		Task.detached { [sigVal] in
			if let handlers = await SignalStack.global.signalStack[sigVal] {
				for handler in handlers {
					handler.handler(sigVal)
				}
			}
		}
	}
	
	public typealias SignalHandler = (Int32) -> Void
	public typealias SignalHandle = UInt64
	
	fileprivate struct KeyedHandler {
		let handle:SignalHandle
		let handler:SignalHandler
	}
	fileprivate var signalStack = [Int32:[KeyedHandler]]()
	
	@discardableResult public func add(signal:Int32, _ handler:@escaping(SignalHandler)) -> SignalHandle {
		let newID = SignalHandle.random(in:SignalHandle.min...SignalHandle.max)
		if var hasStack = signalStack[signal] {
			hasStack.append(KeyedHandler(handle:newID, handler:handler))
			signalStack[signal] = hasStack
		} else {
			reset(signal:signal)
			signalStack[signal] = [KeyedHandler(handle:newID, handler:handler)]
#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
			var signalAction = sigaction(__sigaction_u:unsafeBitCast(SignalStack.mainHandler, to:__sigaction_u.self), sa_mask:0, sa_flags:0)
			_ = withUnsafePointer(to:&signalAction) { handlerPointer in
				sigaction(signal, handlerPointer.pointee, nil)
			}
#elseif os(Linux)
			var signalAction = sigaction()
			signalAction.__sigaction_handler = unsafeBitCast(SignalStack.mainHandler, to:sigaction.__Unnamed_union___sigaction_handler.self)
			_ = sigaction(signal, &signalAction, nil)	
#endif
		}
		return newID
	}
	
	public func remove(signal:Int32, handle:SignalHandle) {
		if var hasStack = signalStack[signal] {
			hasStack.removeAll(where: { $0.handle == handle })
			if (hasStack.count == 0) {
				reset(signal:signal)
				signalStack.removeValue(forKey:signal)
			} else {
				signalStack[signal] = hasStack
			}
		}
	}
	
	public func reset(signal:Int32) {
#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
		_ = Darwin.signal(signal, SIG_DFL)
#elseif os(Linux)
		_ = Glibc.signal(signal, SIG_DFL)		
#endif
	}
	
	public func ignore(signal:Int32) {
#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
		_ = Darwin.signal(signal, SIG_IGN)
#elseif os(Linux)
		_ = Glibc.signal(signal, SIG_IGN)		
#endif
	}
}
