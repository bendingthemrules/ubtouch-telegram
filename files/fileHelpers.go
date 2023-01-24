package files

import (
	"fmt"
	"log"
	"os"
)

func FileExists(name string) bool {
	f, err := os.Stat(name)
	return err == nil && !f.IsDir()
}

func CreateFile(dir string, filename string, content []byte) {
	fmt.Println("Creating " + filename)
	err := os.MkdirAll(dir, 0755)

	if err != nil && !os.IsExist(err) {
		log.Fatal(err)
	}
	err = os.WriteFile(dir+filename, content, 0664)
	if err != nil {
		log.Fatal(err)
	}
}

func ClearFolder(path string) {
	fmt.Println("Clearing downloads folders")
	err := os.RemoveAll(path)
	if err != nil {
		fmt.Println("Tried to clear downloads folder but got an error", err)
	}
}
