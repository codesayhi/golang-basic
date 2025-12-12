package main

import (
	"fmt"
	"log"

	"github.com/codesayhi/golang-basic/pkg/config"
	"github.com/codesayhi/golang-basic/pkg/database"
)

func main() {
	cFig := config.Load()

	db, err := database.Connect(cFig.DriverName, cFig.DBUrl)
	if err != nil {
		log.Fatal(err)
	} else {
		log.Println("Connected to database")
	}
	defer db.Close()
	fmt.Printf("config: %+v\n", cFig)

}
