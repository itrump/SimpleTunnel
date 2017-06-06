/*
	Copyright (C) 2016 Apple Inc. All Rights Reserved.
	See LICENSE.txt for this sample’s licensing information
	
	Abstract:
	This file contains the main code for the SimpleTunnel server.
*/

import Foundation

/// Dispatch source to catch and handle SIGINT
let interruptSignalSource = DispatchSource.makeSignalSource(signal: SIGINT, queue: DispatchQueue.main)


/// Dispatch source to catch and handle SIGTERM
let termSignalSource = DispatchSource.makeSignalSource(signal: SIGTERM, queue: DispatchQueue.main)

/// Basic sanity check of the parameters.
if CommandLine.arguments.count < 3 {
	print("Usage: \(CommandLine.arguments[0]) <port> <config-file>")
	exit(1)
}

func ignore(_: Int32)  {
}
signal(SIGTERM, ignore)
signal(SIGINT, ignore)

let portString = CommandLine.arguments[1]
let configurationPath = CommandLine.arguments[2]
let networkService: NetService

// Initialize the server.

if !ServerTunnel.initializeWithConfigurationFile(path: configurationPath) {
	exit(1)
}

if let portNumber = Int(portString)  {
	networkService = ServerTunnel.startListeningOnPort(port: Int32(portNumber))
}
else {
	print("Invalid port: \(portString)")
	exit(1)
}

// Set up signal handling.

(interruptSignalSource as! DispatchSource).setEventHandler() {
	networkService.stop()
	return
}
(interruptSignalSource as! DispatchObject).resume()

(termSignalSource as! DispatchSource).setEventHandler() {
	networkService.stop()
	return
}
(termSignalSource as! DispatchObject).resume()

RunLoop.main.run()
