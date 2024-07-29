package main

import (
	"fmt"
	"log"
	"os"

	"github.com/gofrs/uuid/v5"
)

func main() {
	if len(os.Args) > 1 && (os.Args[1] == "-h") {
		fmt.Println("Generate a UUID v7 identifier")
		fmt.Println("")
		fmt.Println("Usage: uuid7 [options]")
		fmt.Println("Options:")
		fmt.Println("  -h        Display this help message")
		fmt.Println("  --version Show the version of the application")
		return
	}
	if len(os.Args) > 1 && (os.Args[1] == "-v" || os.Args[1] == "--version") {
		fmt.Println("uuid7 version 0.1")
		fmt.Println("by Rob Allen")
		fmt.Println("https://github.com/akrabat/uuid7")
		return
	}

	u7, err := uuid.NewV7()
	if err != nil {
		log.Fatalf("failed to generate UUID: %v", err)
	}
	fmt.Printf("%v\n", u7)
}
