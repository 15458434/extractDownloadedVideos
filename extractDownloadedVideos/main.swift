//
//  main.swift
//  extractDownloadedVideos
//
//  Created by Mark Cornelisse on 02/04/2024.
//

import Foundation

// Function to check if a path is a directory
func isDirectory(atPath path: String) -> Bool {
    var isDir: ObjCBool = false
    FileManager.default.fileExists(atPath: path, isDirectory: &isDir)
    return isDir.boolValue
}

// Recursive function to list all files and folders at a given path, excluding specific folders
// Moves various types of video files to the "result" directory
func listFilesAndFoldersAndMoveVideos(at path: String, to destinationPath: String, excluding excludedFolders: Set<String>, withIndentation indentation: String = "") {
    let fileManager = FileManager.default
    
    // Define the set of video file extensions to move
    let videoExtensions: Set<String> = ["mp4", "mkv", "avi", "mov", "wmv", "flv"]
    
    do {
        // Get the directory contents URLs (including subfolders).
        let directoryContents = try fileManager.contentsOfDirectory(at: URL(fileURLWithPath: path), includingPropertiesForKeys: nil)
        
        for item in directoryContents {
            let itemName = item.lastPathComponent
            
            // Skip excluded folders
            if excludedFolders.contains(itemName) {
                continue
            }
            
            if isDirectory(atPath: item.path) {
                // If the item is a directory, recursively list its contents
                listFilesAndFoldersAndMoveVideos(at: item.path, to: destinationPath, excluding: excludedFolders, withIndentation: indentation + "  ")
            } else {
                // Check if the file is one of the defined video types and move it to the "result" directory
                if videoExtensions.contains(item.pathExtension.lowercased()) {
                    let destinationURL = URL(fileURLWithPath: destinationPath).appendingPathComponent(itemName)
                    do {
                        try fileManager.moveItem(at: item, to: destinationURL)
                        print("Moved \(itemName) to \(destinationPath)")
                    } catch {
                        print("Could not move \(itemName) to \(destinationPath): \(error)")
                    }
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

let excludedFolders: Set<String> = ["incomplete", "result"] // Folders to exclude
let resultFolderPath = "\(path)/result" // Path to the "result" folder

// Ensure the "result" folder exists
let fileManager = FileManager.default
if !fileManager.fileExists(atPath: resultFolderPath) {
    do {
        try fileManager.createDirectory(atPath: resultFolderPath, withIntermediateDirectories: true)
    } catch {
        print("Failed to create directory 'result': \(error)")
        exit(1)
    }
}

listFilesAndFoldersAndMoveVideos(at: path, to: resultFolderPath, excluding: excludedFolders)
