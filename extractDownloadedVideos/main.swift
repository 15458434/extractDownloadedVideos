//
//  main.swift
//  extractDownloadedVideos
//
//  Created by Mark Cornelisse on 02/04/2024.
//

import Foundation

var videoFiles: [URL] = [] // Global array to store .mp4 and .mkv file URLs

// Function to check if a path is a directory
func isDirectory(atPath path: String) -> Bool {
    var isDir: ObjCBool = false
    FileManager.default.fileExists(atPath: path, isDirectory: &isDir)
    return isDir.boolValue
}

// Recursive function to list all files and folders at a given path and collect .mp4 and .mkv files
func listFilesAndFolders(at path: String, withIndentation indentation: String = "") {
    let fileManager = FileManager.default
    
    do {
        // Get the directory contents URLs (including subfolders).
        let directoryContents = try fileManager.contentsOfDirectory(at: URL(fileURLWithPath: path), includingPropertiesForKeys: nil)
        
        for item in directoryContents {
            // Print all files and folders
            print("\(indentation)\(item.lastPathComponent)")
            if isDirectory(atPath: item.path) {
                // If the item is a directory, recursively list its contents
                listFilesAndFolders(at: item.path, withIndentation: indentation + "  ")
            } else {
                // Check for .mp4 and .mkv files and add them to the array
                if item.pathExtension == "mp4" || item.pathExtension == "mkv" {
                    videoFiles.append(item)
                }
            }
        }
    } catch {
        print(error.localizedDescription)
    }
}

// Main program
let arguments = CommandLine.arguments

let path: String
if arguments.count > 1 {
    path = arguments[1] // Use the first argument as the path
} else {
    path = FileManager.default.currentDirectoryPath // Default to current directory
}

print("Listing all files and subfolders in: \(path)\n")
listFilesAndFolders(at: path)

// Print the collected .mp4 and .mkv file URLs
print("\nCollected .mp4 and .mkv file URLs:")
for file in videoFiles {
    print(file.absoluteString)
}



