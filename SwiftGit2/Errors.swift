import Foundation
import libgit2

public let libGit2ErrorDomain = "org.libgit2.libgit2"

/// Returns an NSError with an error domain and message for libgit2 errors.
///
/// :param: errorCode An error code returned by a libgit2 function.
/// :param: libGit2PointOfFailure The name of the libgit2 function that produced the
///         error code.
/// :returns: An NSError with a libgit2 error domain, code, and message.
internal func libGit2Error(_ errorCode: Int32, libGit2PointOfFailure: String? = nil) -> NSError {
	let code = Int(errorCode)
	var userInfo: [String: String] = [:]

	if let message = errorMessage(errorCode) {
		userInfo[NSLocalizedDescriptionKey] = message
	} else {
		userInfo[NSLocalizedDescriptionKey] = "Unknown libgit2 error."
	}

	if let pointOfFailure = libGit2PointOfFailure {
		userInfo[NSLocalizedFailureReasonErrorKey] = "\(pointOfFailure) failed."
	}

	return NSError(domain: libGit2ErrorDomain, code: code, userInfo: userInfo)
}


/// Returns the libgit2 error message for the given error code.
///
/// The error message represents the last error message generated by
/// libgit2 in the current thread.
///
/// :param: errorCode An error code returned by a libgit2 function.
/// :returns: If the error message exists either in libgit2's thread-specific registry,
///           or errno has been set by the system, this function returns the
///           corresponding string representation of that error. Otherwise, it returns
///           nil.
private func errorMessage(_ errorCode: Int32) -> String? {
	let last = giterr_last()
	if let lastErrorPointer = last {
		return String(validatingUTF8: lastErrorPointer.pointee.message)
	} else if UInt32(errorCode) == GITERR_OS.rawValue {
		return String(validatingUTF8: strerror(errno))
	} else {
		return nil
	}
}
