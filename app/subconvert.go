//nolint:unparam
package main

import (
    "fmt"
    "os"
    "encoding/json"
    "subconvert/nodep"
)

func main() {

    url :=os.Args[1]
    xrayJson, err := nodep.ConvertShareLinksToXrayJson(url)

    if err != nil {
        fmt.Fprintf(os.Stderr, "error: %v\n", err)
        os.Exit(1)
    }

    output, err := json.MarshalIndent(xrayJson, "", "    ")
    if err != nil {
        fmt.Fprintf(os.Stderr, "error: %v\n", err)
        os.Exit(1)
    }

    fmt.Println(string(output))

}
