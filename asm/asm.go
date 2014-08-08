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
    parser.ParserParse(scan)
    scan.ScanOk()
}
