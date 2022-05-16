package main

import (
	"tftpserver/go-tftp"
	_ "tftpserver/go-sqlite3"
	"database/sql"
	"log"
	"os"
	"io"
	"io/ioutil"
	// _ "github.com/mattn/go-sqlite3"
)

func main() {
	db, err := sql.Open("sqlite3", "tftp.db")
	s, err := tftp.NewServer(":69", tftp.ServerSinglePort(true))
	if err != nil {
		panic(err)
	}
	readHandler := tftp.ReadHandlerFunc(proxyTFTP)
	s.ReadHandler(readHandler)
	s.WriteHandler(&tftpDB{db})
	s.ListenAndServe()
	select{}

}

type tftpDB struct {
	*sql.DB
}

func (db *tftpDB) ReceiveTFTP(w tftp.WriteRequest) {
	// Get the file size

	//REMEMBER! Compare with the existing examples and clean this up, I've had to bypass
	//some error return lines... 



	logfile, _ := os.OpenFile("log.txt", os.O_CREATE|os.O_APPEND|os.O_WRONLY, 0666)
	log.SetOutput(logfile)

	log.Printf("[%s] PUT %s (%s)\n", w.Addr().IP.String(), w.Name(), w.TransferMode() )
	data, err := ioutil.ReadAll(w)
	ioutil.WriteFile(w.Name(), data, 0777)

	// Note: The size value is sent by the client, the client could send more data than
	// it indicated in the size option. To be safe we'd want to allocate a buffer
	// with the size we're expecting and use w.Read(buf) rather than ioutil.ReadAll.

	// Read the data from the client into memory

	if err != nil {
		log.SetOutput(logfile)
		log.Println("Error running ReadAll(w)")
		log.SetOutput(logfile)
		log.Println(err)
		return
	}

	// Insert the IP address of the client and the data into the database
	res, err := db.Exec("INSERT INTO tftplogs (ip, log) VALUES (?, ?)", w.Addr().IP.String(), string(data))
	if err != nil {
		log.SetOutput(logfile)
		log.Println(err)
		return
	}

	// Log a message with the details
	id, _ := res.LastInsertId()
	log.SetOutput(logfile)
	log.Printf("Inserted %d bytes of data from %s. (ID=%d)", len(data), w.Addr().IP, id)
}

//type ReadRequest defined in handlers.go
func proxyTFTP(w tftp.ReadRequest) {
	logfile, _ := os.OpenFile("log.txt", os.O_CREATE|os.O_APPEND|os.O_WRONLY, 0666)
	log.SetOutput(logfile)
	log.Printf("[%s] GET %s (%s)\n", w.Addr().IP.String(), w.Name(), w.TransferMode() )
	file, err := os.Open("/tftpboot/" + w.Name()) // For read access.
	if err != nil {
		logfile, _ := os.OpenFile("log.txt", os.O_CREATE|os.O_APPEND|os.O_WRONLY, 0666)
		log.SetOutput(logfile)
		log.Println(err)
		w.WriteError(tftp.ErrCodeFileNotFound, err.Error())
		return
	}
	defer file.Close()

	if _, err := io.Copy(w, file); err != nil {
		log.Println(err)
	}
}
