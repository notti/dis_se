package main

import (
    "io/ioutil"
    "os"
    "scanner"
    "parser"
)

func main() {
    input, err := ioutil.ReadFile(os.Args[1])
    if err != nil { panic(err) }

    scan := scanner.NewScanner(input)
    if parser.ParserParse(scan) == 0 {
        scan.ScanOk()
    }
}
